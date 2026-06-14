const resetService = require('../../domain/services/resetPasswordService');

// POST /forgot-password
exports.demanderReset = async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'Email obligatoire' });
    }
    const result = await resetService.demanderReset(email);
    return res.status(200).json(result);
  } catch (err) {
    // ✅ FIX: ne pas laisser next(err) afficher "erreur serveur" pour les erreurs connues
    if (err.message.includes('obligatoire')) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
};

// POST /change-password
exports.changerMotDePasse = async (req, res, next) => {
  try {
    const { email, ancienMdp, nouveauMdp } = req.body;
    const result = await resetService.changerMotDePasse({ email, ancienMdp, nouveauMdp });
    return res.status(200).json(result);
  } catch (err) {
    const clientErrors = ['obligatoire', 'incorrect', 'introuvable', 'caractères'];
    if (clientErrors.some(e => err.message.includes(e))) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
};
