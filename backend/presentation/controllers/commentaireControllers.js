const commentaireService = require('../../domain/services/commentaireService');

// PATCH /signalements/commentaires/:id
exports.updateCommentaire = async (req, res, next) => {
  try {
    const message = req.body.contenu || req.body.message;
    if (!message || message.trim().length === 0) {
      return res.status(400).json({ error: 'Le message est obligatoire' });
    }
    const updated = await commentaireService.updateCommentaire(req.params.id, { message });
    if (!updated) {
      return res.status(404).json({ error: 'Commentaire introuvable' });
    }
    return res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
};

// DELETE /signalements/commentaires/:id
exports.deleteCommentaire = async (req, res, next) => {
  try {
    await commentaireService.deleteCommentaire(req.params.id);
    return res.status(200).json({ message: 'Commentaire supprimé' });
  } catch (err) {
    next(err);
  }
};

/*const commentaireService = require('../../domain/services/commentaireService');
const pool = require('../../infrastructure/database/db');
const { adaptCommentaire } = require('../adapters/responseAdapter');

exports.create = async (req, res) => {
  try {
    const idUtilisateur = req.user.id;
    const { message, contenu } = req.body;
    const commentaire = await commentaireService.createCommentaire({
      message: message || contenu,
      idSignalement: req.params.signalementId,
      idUtilisateur
    });
    res.status(201).json(adaptCommentaire(commentaire));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.list = async (req, res) => {
  try {
    const commentaires = await commentaireService.getCommentaires(req.params.signalementId);
    res.json(commentaires.map(adaptCommentaire));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const utilisateurId = req.user.id;
    const userRole = req.user.role;

    // Récupérer le commentaire pour vérifier la propriété
    const result = await pool.query(
      'SELECT * FROM commentaires WHERE id_commentaire = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Commentaire introuvable' });
    }

    const commentaireActuel = result.rows[0];

    // Vérifier les permissions : seulement l'auteur ou un admin peut éditer
    if (commentaireActuel.id_utilisateur !== utilisateurId && userRole !== 'admin') {
      return res.status(403).json({ error: 'Vous n\'avez pas la permission d\'éditer ce commentaire' });
    }

    const { message, contenu } = req.body;
    const commentaire = await commentaireService.updateCommentaire(id, {
      message: message || contenu,
    });
    
    res.json(adaptCommentaire(commentaire));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    const utilisateurId = req.user.id;
    const userRole = req.user.role;

    // Récupérer le commentaire pour vérifier la propriété
    const result = await pool.query(
      'SELECT * FROM commentaires WHERE id_commentaire = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Commentaire introuvable' });
    }

    const commentaire = result.rows[0];

    // Vérifier les permissions : seulement l'auteur ou un admin peut supprimer
    if (commentaire.id_utilisateur !== utilisateurId && userRole !== 'admin') {
      return res.status(403).json({ error: 'Vous n\'avez pas la permission de supprimer ce commentaire' });
    }

    await commentaireService.deleteCommentaire(id);
    res.json({ message: 'Commentaire supprimé' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};*/
