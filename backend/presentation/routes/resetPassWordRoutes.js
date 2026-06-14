const router = require('express').Router();
const resetController = require('../controllers/resetPasswordController');
const { authenticate } = require('../routes/middleware');

// POST /forgot-password — public (pas besoin d'être connecté)
router.post('/forgot-password', resetController.demanderReset);

// POST /change-password — connecté (token requis)
router.post('/change-password', authenticate, resetController.changerMotDePasse);

module.exports = router;
