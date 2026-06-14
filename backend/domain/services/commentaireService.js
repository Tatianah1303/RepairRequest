const pool = require('../../infrastructure/database/db');

exports.createCommentaire = async ({ message, idSignalement, idUtilisateur }) => {
  // Insère le commentaire et récupère son ID
  const insert = await pool.query(
    `INSERT INTO commentaires (message, date_commentaire, id_signalement, id_utilisateur)
     VALUES ($1, CURRENT_TIMESTAMP, $2, $3)
     RETURNING id_commentaire`,
    [message, idSignalement, idUtilisateur]
  );
  const newId = insert.rows[0].id_commentaire;

  // Récupère le commentaire complet avec les infos utilisateur — par ID exact (plus de bug de doublon)
  const result = await pool.query(
    `SELECT c.*, u.nom AS nom_utilisateur, u.role
     FROM commentaires c
     JOIN utilisateurs u ON c.id_utilisateur = u.id_utilisateur
     WHERE c.id_commentaire = $1`,
    [newId]
  );
  return result.rows[0];
};

exports.getCommentaires = async (signalementId) => {
  const result = await pool.query(
    `SELECT c.*, u.nom AS nom_utilisateur, u.role
     FROM commentaires c
     JOIN utilisateurs u ON c.id_utilisateur = u.id_utilisateur
     WHERE c.id_signalement = $1
     ORDER BY c.date_commentaire ASC`,
    [signalementId]
  );
  return result.rows;
};

exports.updateCommentaire = async (id, { message }) => {
  const result = await pool.query(
    `UPDATE commentaires
     SET message = $1
     WHERE id_commentaire = $2
     RETURNING *`,
    [message, id]
  );
  return result.rows[0];
};

exports.deleteCommentaire = async (id) => {
  await pool.query('DELETE FROM commentaires WHERE id_commentaire = $1', [id]);
};
