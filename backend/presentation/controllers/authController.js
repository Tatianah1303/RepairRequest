const authService = require('../../domain/services/authService');

// POST /auth/register  ou  POST /register
exports.register = async (req, res, next) => {
  try {
    const { nom, email, mot_de_passe, role, specialite } = req.body;
    if (!nom || !email || !mot_de_passe) {
      return res.status(400).json({ error: 'Nom, email et mot de passe sont obligatoires' });
    }
    const user = await authService.register({ nom, email, mot_de_passe, role, specialite });
    return res.status(201).json(user);
  } catch (err) {
    if (err.message.includes('déjà utilisé') || err.message.includes('already')) {
      return res.status(409).json({ error: err.message });
    }
    next(err);
  }
};

// POST /auth/login  ou  POST /login
exports.login = async (req, res, next) => {
  try {
    const { email, mot_de_passe } = req.body;
    if (!email || !mot_de_passe) {
      return res.status(400).json({ error: 'Email et mot de passe sont obligatoires' });
    }
    const result = await authService.login({ email, mot_de_passe });
    return res.status(200).json(result);
  } catch (err) {
    if (err.message.includes('introuvable') || err.message.includes('incorrect')) {
      return res.status(401).json({ error: err.message });
    }
    next(err);
  }
};
