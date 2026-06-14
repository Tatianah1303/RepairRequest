const pool = require('../../infrastructure/database/db');

// POST /signalements
exports.createSignalement = async ({
  titre, description, batiment, adresse, quartier,
  statut, categorie, priorite, utilisateurId
}) => {
  const result = await pool.query(
    `INSERT INTO signalements
       (titre, description, batiment, adresse, quartier, statut, categorie, priorite, date_signalement, id_utilisateur)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,CURRENT_TIMESTAMP,$9)
     RETURNING *`,
    [
      titre, description, batiment,
      adresse || '', quartier || '',
      statut    || 'en attente',
      categorie || 'Autre',
      priorite  || 'normal',
      utilisateurId
    ]
  );
  return result.rows[0];
};

// GET /signalements — avec nom du technicien et du résident
exports.getSignalements = async () => {
  const result = await pool.query(`
    SELECT s.*,
           u.nom  AS nom_resident,
           t.nom  AS nom_technicien,
           t.specialite AS specialite_technicien
    FROM signalements s
    LEFT JOIN utilisateurs u ON s.id_utilisateur   = u.id_utilisateur
    LEFT JOIN utilisateurs t ON s.id_technicien    = t.id_utilisateur
    ORDER BY
      CASE s.priorite
        WHEN 'urgent' THEN 1
        WHEN 'normal' THEN 2
        WHEN 'faible' THEN 3
        ELSE 4
      END,
      s.date_signalement DESC
  `);
  return result.rows;
};

// GET /signalements/:id
exports.getSignalementById = async (id) => {
  const result = await pool.query(`
    SELECT s.*,
           u.nom  AS nom_resident,
           t.nom  AS nom_technicien,
           t.specialite AS specialite_technicien
    FROM signalements s
    LEFT JOIN utilisateurs u ON s.id_utilisateur = u.id_utilisateur
    LEFT JOIN utilisateurs t ON s.id_technicien  = t.id_utilisateur
    WHERE s.id_signalement = $1
  `, [id]);
  return result.rows[0];
};

// PATCH /signalements/:id — avec historique automatique
exports.updateSignalement = async (id, {
  titre, description, batiment, adresse,
  quartier, statut, categorie, priorite,
  id_technicien, utilisateurId
}) => {
  const current = await pool.query(
    'SELECT * FROM signalements WHERE id_signalement = $1', [id]
  );
  if (current.rows.length === 0) return null;
  const c = current.rows[0];

  // ✅ Enregistrer historique si le statut change
  if (statut && statut !== c.statut) {
    await pool.query(
      `INSERT INTO historique_statuts
         (id_signalement, ancien_statut, nouveau_statut, id_utilisateur)
       VALUES ($1, $2, $3, $4)`,
      [id, c.statut, statut, utilisateurId || null]
    );
  }

  const result = await pool.query(
    `UPDATE signalements
     SET titre         = $1,
         description   = $2,
         batiment      = $3,
         adresse       = $4,
         quartier      = $5,
         statut        = $6,
         categorie     = $7,
         priorite      = $8,
         id_technicien = $9
     WHERE id_signalement = $10
     RETURNING *`,
    [
      titre         ?? c.titre,
      description   ?? c.description,
      batiment      ?? c.batiment,
      adresse       ?? c.adresse,
      quartier      ?? c.quartier,
      statut        ?? c.statut,
      categorie     ?? c.categorie,
      priorite      ?? c.priorite,
      id_technicien !== undefined ? id_technicien : c.id_technicien,
      id
    ]
  );
  return result.rows[0];
};

// DELETE /signalements/:id
exports.deleteSignalement = async (id) => {
  await pool.query('DELETE FROM signalements WHERE id_signalement = $1', [id]);
};

// GET /signalements/:id/historique
exports.getHistorique = async (id) => {
  const result = await pool.query(`
    SELECT h.*, u.nom AS nom_utilisateur, u.role
    FROM historique_statuts h
    LEFT JOIN utilisateurs u ON h.id_utilisateur = u.id_utilisateur
    WHERE h.id_signalement = $1
    ORDER BY h.date_changement ASC
  `, [id]);
  return result.rows;
};
