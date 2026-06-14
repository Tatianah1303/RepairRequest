const express = require('express');
const router = express.Router();
const commentaireController = require('../controllers/commentaireControllers');
const { authenticate } = require('../middleware/authMiddleware');

router.post('/', authenticate, commentaireController.create);
router.get('/:signalementId', authenticate, commentaireController.list);

// ✏️ Éditer un commentaire
router.patch('/:id', authenticate, commentaireController.update);

// 🗑️ Supprimer un commentaire
router.delete('/:id', authenticate, commentaireController.delete);

module.exports = router;
