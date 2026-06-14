const pool = require('../../infrastructure/database/db');

// GET /users — liste tous les utilisateurs (admin)
exports.getAllUsers = async (req, res, next) => {
  try {
    const result = await pool.query(
      'SELECT id_utilisateur, nom, email, role, specialite, date_creation FROM utilisateurs ORDER BY date_creation DESC'
    );
    return res.status(200).json(result.rows);
  } catch (err) {
    next(err);
  }
};

// GET /users/:id — profil d'un utilisateur
exports.getUserById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id_utilisateur, nom, email, role, specialite, date_creation FROM utilisateurs WHERE id_utilisateur = $1',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur introuvable' });
    }
    return res.status(200).json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /users/:id — supprimer un utilisateur (admin)
exports.deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM utilisateurs WHERE id_utilisateur = $1', [id]);
    return res.status(200).json({ message: 'Utilisateur supprimé' });
  } catch (err) {
    next(err);
  }
};