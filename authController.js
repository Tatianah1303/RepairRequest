const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
    const { nom_utilisateur, email, mot_de_passe, role } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
        const result = await db.query(
            'INSERT INTO Utilisateurs (nom_utilisateur, email, mot_de_passe, role) VALUES ($1, $2, $3, $4) RETURNING id, nom_utilisateur, email, role',
            [nom_utilisateur, email, hashedPassword, role || 'resident']
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.login = async (req, res) => {
    const { email, mot_de_passe } = req.body;
    try {
        const result = await db.query('SELECT * FROM Utilisateurs WHERE email = $1', [email]);
        if (result.rows.length === 0) return res.status(404).json({ message: "Utilisateur non trouvé" });

        const user = result.rows[0];
        const isMatch = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
        if (!isMatch) return res.status(400).json({ message: "Mot de passe incorrect" });

        const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '24h' });
        res.json({ token, user: { id: user.id, nom_utilisateur: user.nom_utilisateur, email: user.email, role: user.role } });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};