const router = require('express').Router();
const { authenticate } = require('../routes/middleware');
const {
  createSignalement, getAllSignalements, getStats,
  getSignalementById, updateSignalement, deleteSignalement,
  assignerTechnicien, getHistorique,
  getCommentaires, createCommentaire,
} = require('../controllers/signalementController');
const { updateCommentaire, deleteCommentaire } = require('../controllers/commentaireControllers');

// ⚠️ Routes statiques AVANT /:id
router.get('/stats',                authenticate, getStats);
router.patch('/commentaires/:id',   authenticate, updateCommentaire);
router.delete('/commentaires/:id',  authenticate, deleteCommentaire);

// CRUD signalements
router.post('/',    authenticate, createSignalement);
router.get('/',     authenticate, getAllSignalements);
router.get('/:id',  authenticate, getSignalementById);
router.patch('/:id',authenticate, updateSignalement);
router.delete('/:id',authenticate,deleteSignalement);

// ✅ Nouveau : technicien prend en charge
router.patch('/:id/assigner', authenticate, assignerTechnicien);

// ✅ Nouveau : historique des statuts
router.get('/:id/historique', authenticate, getHistorique);

// Commentaires
router.get('/:id/commentaires',  authenticate, getCommentaires);
router.post('/:id/commentaires', authenticate, createCommentaire);

module.exports = router;
