const router = require('express').Router();
const { authenticate } = require('../routes/middleware');
const { getAllUsers, getUserById, deleteUser } = require('../controllers/userController');

// GET /users
router.get('/', authenticate, getAllUsers);

// GET /users/:id
router.get('/:id', authenticate, getUserById);

// DELETE /users/:id
router.delete('/:id', authenticate, deleteUser);

module.exports = router;
