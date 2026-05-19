const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const signalementController = require('../controllers/signalementController');
const auth = require('../middleware/auth');

// Routes Authentification
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);

// Routes Signalements
router.post('/signalements', auth, signalementController.createSignalement);
router.get('/signalements', auth, signalementController.getAllSignalements);
router.get('/signalements/:id', auth, signalementController.getSignalementById);
router.patch('/signalements/:id/statut', auth, signalementController.updateStatut);

module.exports = router;