const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Connexion PostgreSQL
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
});

const JWT_SECRET = process.env.JWT_SECRET || 'votre_cle_secrete_tres_longue';

// Middleware pour protéger les routes
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ message: "Accès refusé" });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: "Token invalide" });
    req.user = user;
    next();
  });
};

// --- AUTHENTIFICATION ---

// Inscription
app.post('/register', async (req, res) => {
  const { nom, email, mot_de_passe, role, specialite } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
    // On n'ajoute la spécialité que si c'est un technicien
    const userSpecialite = role === 'technicien' ? specialite : null;
    
    const result = await pool.query(
      'INSERT INTO utilisateurs (nom, email, mot_de_passe, role, specialite, date_creation) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP) RETURNING id_utilisateur, nom, email, role',
      [nom, email, hashedPassword, role, userSpecialite]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Connexion
app.post('/login', async (req, res) => {
  const { email, mot_de_passe } = req.body;
  try {
    const result = await pool.query('SELECT * FROM utilisateurs WHERE email = $1', [email]);
    if (result.rows.length === 0) return res.status(404).json({ message: "Utilisateur non trouvé" });

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!validPassword) return res.status(400).json({ message: "Mot de passe incorrect" });

    const token = jwt.sign({ id: user.id_utilisateur, role: user.role }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ token, user: { id: user.id_utilisateur, nom: user.nom, email: user.email, role: user.role, specialite: user.specialite } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- SIGNALEMENTS ---

// Créer un signalement
app.post('/signalements', authenticateToken, async (req, res) => {
  const { titre, description, adresse, quartier } = req.body;
  const id_utilisateur = req.user.id;
  try {
    const result = await pool.query(
      'INSERT INTO signalements (titre, description, adresse, quartier, statut, date_signalement, id_utilisateur) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, $6) RETURNING *',
      [titre, description, adresse, quartier, 'En attente', id_utilisateur]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer tous les signalements (ou ceux de l'utilisateur connecté)
app.get('/signalements', authenticateToken, async (req, res) => {
  try {
    let query = 'SELECT s.*, u.nom as nom_createur FROM signalements s JOIN utilisateurs u ON s.id_utilisateur = u.id_utilisateur';
    let params = [];
    
    if (req.user.role === 'user') {
      query += ' WHERE s.id_utilisateur = $1';
      params.push(req.user.id);
    } else if (req.user.role === 'technicien') {
      query += ' WHERE s.id_technicien = $1 OR s.id_technicien IS NULL';
      params.push(req.user.id);
    }
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Assigner un technicien ou changer statut
app.patch('/signalements/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { statut, id_technicien } = req.body;
  try {
    const result = await pool.query(
      'UPDATE signalements SET statut = COALESCE($1, statut), id_technicien = COALESCE($2, id_technicien) WHERE id_signalement = $3 RETURNING *',
      [statut, id_technicien, id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- MINI-CHAT (COMMENTAIRES) ---

// Envoyer un message/commentaire
app.post('/commentaires', authenticateToken, async (req, res) => {
  const { id_signalement, message } = req.body;
  const id_utilisateur = req.user.id;
  try {
    const result = await pool.query(
      'INSERT INTO commentaires (message, date_commentaire, id_signalement, id_utilisateur) VALUES ($1, CURRENT_TIMESTAMP, $2, $3) RETURNING *',
      [message, id_signalement, id_utilisateur]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer les messages d'un signalement
app.get('/signalements/:id/commentaires', authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'SELECT c.*, u.nom, u.role FROM commentaires c JOIN utilisateurs u ON c.id_utilisateur = u.id_utilisateur WHERE c.id_signalement = $1 ORDER BY c.date_commentaire ASC',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});