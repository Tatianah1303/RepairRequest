const db = require('../config/db');

exports.createSignalement = async (req, res) => {
    const { immeuble_id, titre, description, priorite } = req.body;
    const utilisateur_id = req.user.id;
    try {
        const result = await db.query(
            'INSERT INTO Signalements (utilisateur_id, immeuble_id, titre, description, priorite) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [utilisateur_id, immeuble_id, titre, description, priorite || 'normal']
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getAllSignalements = async (req, res) => {
    try {
        const result = await db.query(`
            SELECT s.*, u.nom_utilisateur, i.adresse 
            FROM Signalements s
            JOIN Utilisateurs u ON s.utilisateur_id = u.id
            JOIN Immeubles i ON s.immeuble_id = i.id
            ORDER BY s.date_creation DESC
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getSignalementById = async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM Signalements WHERE id = $1', [req.params.id]);
        if (result.rows.length === 0) return res.status(404).json({ message: "Signalement non trouvé" });
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updateStatut = async (req, res) => {
    const { statut } = req.body;
    try {
        const result = await db.query(
            'UPDATE Signalements SET statut = $1, date_mise_a_jour = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
            [statut, req.params.id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};