const signalementService = require('../../domain/services/signalementService');
const commentaireService = require('../../domain/services/commentaireService');
const pool = require('../../infrastructure/database/db');

// POST /signalements — résident crée un signalement
exports.createSignalement = async (req, res, next) => {
  try {
    const { titre, description, batiment, adresse, quartier, categorie, priorite } = req.body;
    if (!titre || !description || !batiment) {
      return res.status(400).json({ error: 'Titre, description et bâtiment sont obligatoires' });
    }
    const signalement = await signalementService.createSignalement({
      titre, description, batiment,
      adresse:   adresse   || '',
      quartier:  quartier  || '',
      categorie: categorie || 'Autre',
      priorite:  priorite  || 'normal',
      statut:    'en attente',
      utilisateurId: req.user?.id,
    });
    return res.status(201).json({ ...signalement, id: signalement.id_signalement });
  } catch (err) { next(err); }
};

// GET /signalements — liste selon le rôle
exports.getAllSignalements = async (req, res, next) => {
  try {
    const { id, role } = req.user;
    let signalements;

    if (role === 'resident') {
      // ✅ Résident voit SEULEMENT ses propres signalements
      const result = await pool.query(`
        SELECT s.*, u.nom AS nom_resident,
               t.nom AS nom_technicien, t.specialite AS specialite_technicien
        FROM signalements s
        LEFT JOIN utilisateurs u ON s.id_utilisateur  = u.id_utilisateur
        LEFT JOIN utilisateurs t ON s.id_technicien   = t.id_utilisateur
        WHERE s.id_utilisateur = $1
        ORDER BY CASE s.priorite WHEN 'urgent' THEN 1 WHEN 'normal' THEN 2 ELSE 3 END,
                 s.date_signalement DESC
      `, [id]);
      signalements = result.rows;
    } else {
      // ✅ Technicien et Admin voient TOUS les signalements
      signalements = await signalementService.getSignalements();
    }
    return res.status(200).json(signalements);
  } catch (err) { next(err); }
};

// GET /signalements/stats
exports.getStats = async (req, res, next) => {
  try {
    const { id, role } = req.user;
    let whereClause = '';
    let params = [];

    // Résident voit stats de ses signalements seulement
    if (role === 'resident') {
      whereClause = 'WHERE id_utilisateur = $1';
      params = [id];
    }

    const result = await pool.query(`
      SELECT
        COUNT(*) FILTER (WHERE statut = 'en attente') AS "enAttente",
        COUNT(*) FILTER (WHERE statut = 'en cours')   AS "enCours",
        COUNT(*) FILTER (WHERE statut = 'refusé')     AS "refuse",
        COUNT(*) FILTER (WHERE statut = 'terminé')    AS "termine",
        COUNT(*)                                       AS "total"
      FROM signalements ${whereClause}
    `, params);

    const row   = result.rows[0];
    const total = parseInt(row.total) || 1;
    return res.status(200).json({
      enAttente: ((parseInt(row.enAttente) / total) * 100).toFixed(2),
      enCours:   ((parseInt(row.enCours)   / total) * 100).toFixed(2),
      refuse:    ((parseInt(row.refuse)    / total) * 100).toFixed(2),
      termine:   ((parseInt(row.termine)   / total) * 100).toFixed(2),
      total:     parseInt(row.total),
    });
  } catch (err) { next(err); }
};

// GET /signalements/:id
exports.getSignalementById = async (req, res, next) => {
  try {
    const signalement = await signalementService.getSignalementById(req.params.id);
    if (!signalement) return res.status(404).json({ error: 'Signalement introuvable' });

    // Résident ne peut voir que ses propres signalements
    if (req.user.role === 'resident' && signalement.id_utilisateur !== req.user.id) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    return res.status(200).json(signalement);
  } catch (err) { next(err); }
};

// ✅ PATCH /signalements/:id — règles par rôle
exports.updateSignalement = async (req, res, next) => {
  try {
    const { id, role } = req.user;
    const signalement = await signalementService.getSignalementById(req.params.id);
    if (!signalement) return res.status(404).json({ error: 'Signalement introuvable' });

    let updateData = {};

    if (role === 'resident') {
      // ✅ Résident : peut éditer titre/description/batiment/adresse/quartier
      //               MAIS PAS le statut et PAS si ce n'est pas le sien
      if (signalement.id_utilisateur !== id) {
        return res.status(403).json({ error: 'Vous ne pouvez modifier que vos propres signalements' });
      }
      const { titre, description, batiment, adresse, quartier, categorie, priorite } = req.body;
      updateData = { titre, description, batiment, adresse, quartier, categorie, priorite };
      // Force le statut actuel (le résident ne peut pas le changer)
      updateData.statut = signalement.statut;

    } else if (role === 'technicien') {
      // ✅ Technicien : peut SEULEMENT changer le statut
      const { statut } = req.body;
      const statutsValides = ['en attente', 'en cours', 'refusé', 'terminé'];
      if (!statut || !statutsValides.includes(statut)) {
        return res.status(400).json({ error: `Statut invalide. Valeurs: ${statutsValides.join(', ')}` });
      }
      updateData = {
        titre:       signalement.titre,
        description: signalement.description,
        batiment:    signalement.batiment,
        adresse:     signalement.adresse,
        quartier:    signalement.quartier,
        categorie:   signalement.categorie,
        priorite:    signalement.priorite,
        statut,
      };

    } else if (role === 'admin') {
      // ✅ Admin : peut tout modifier
      updateData = req.body;
    }

    const updated = await signalementService.updateSignalement(
      req.params.id, { ...updateData, utilisateurId: id }
    );
    return res.status(200).json(updated);
  } catch (err) { next(err); }
};

// ✅ PATCH /signalements/:id/assigner — technicien prend en charge
exports.assignerTechnicien = async (req, res, next) => {
  try {
    const { id, role } = req.user;
    if (role !== 'technicien' && role !== 'admin') {
      return res.status(403).json({ error: 'Réservé aux techniciens' });
    }
    const updated = await signalementService.updateSignalement(req.params.id, {
      id_technicien: id,
      statut: 'en cours',
      utilisateurId: id,
    });
    if (!updated) return res.status(404).json({ error: 'Signalement introuvable' });
    return res.status(200).json({ message: 'Signalement pris en charge', signalement: updated });
  } catch (err) { next(err); }
};

// ✅ DELETE /signalements/:id — résident supprime SON signalement, admin supprime tout
exports.deleteSignalement = async (req, res, next) => {
  try {
    const { id, role } = req.user;

    if (role === 'technicien') {
      // ✅ Technicien NE PEUT PAS supprimer
      return res.status(403).json({ error: 'Les techniciens ne peuvent pas supprimer les signalements' });
    }

    if (role === 'resident') {
      // ✅ Résident peut supprimer SEULEMENT ses propres signalements
      const signalement = await signalementService.getSignalementById(req.params.id);
      if (!signalement) return res.status(404).json({ error: 'Signalement introuvable' });
      if (signalement.id_utilisateur !== id) {
        return res.status(403).json({ error: 'Vous ne pouvez supprimer que vos propres signalements' });
      }
    }

    await signalementService.deleteSignalement(req.params.id);
    return res.status(200).json({ message: 'Signalement supprimé' });
  } catch (err) { next(err); }
};

// GET /signalements/:id/historique
exports.getHistorique = async (req, res, next) => {
  try {
    const historique = await signalementService.getHistorique(req.params.id);
    return res.status(200).json(historique);
  } catch (err) { next(err); }
};

// GET /signalements/:id/commentaires
exports.getCommentaires = async (req, res, next) => {
  try {
    const commentaires = await commentaireService.getCommentaires(req.params.id);
    return res.status(200).json(commentaires);
  } catch (err) { next(err); }
};

// POST /signalements/:id/commentaires
exports.createCommentaire = async (req, res, next) => {
  try {
    const message = req.body.contenu || req.body.message;
    if (!message?.trim()) return res.status(400).json({ error: 'Le message est obligatoire' });
    const commentaire = await commentaireService.createCommentaire({
      message, idSignalement: req.params.id, idUtilisateur: req.user?.id,
    });
    return res.status(201).json(commentaire);
  } catch (err) { next(err); }
};
