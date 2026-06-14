const router = require('express').Router();

// ✅ FIX: register et login viennent de authController
const { register, login }                    = require('../controllers/authController');
// ✅ FIX: users viennent de userController
const { getAllUsers, getUserById, deleteUser } = require('../controllers/userController');
const resetController = require('../controllers/resetPasswordController');
const { authenticate } = require('../routes/middleware');

// Auth public
router.post('/register', register);
router.post('/login',    login);

// Mot de passe oublié — public (pas besoin de token)
router.post('/forgot-password', resetController.demanderReset);

// Changer mot de passe — connecté
router.post('/change-password', authenticate, resetController.changerMotDePasse);

// Users — protégés
router.get('/users',        authenticate, getAllUsers);
router.get('/users/:id',    authenticate, getUserById);
router.delete('/users/:id', authenticate, deleteUser);

module.exports = router;