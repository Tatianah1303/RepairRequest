const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const authRoutes        = require('./presentation/routes/authRoutes');
const signalementRoutes = require('./presentation/routes/signalementRoutes');

// Toutes les routes auth + users + reset mdp
app.use('/', authRoutes);

// Signalements + commentaires
app.use('/signalements', signalementRoutes);

// Gestion erreurs
app.use((err, req, res, next) => {
  console.error('❌', err.message);
  res.status(500).json({ error: err.message || 'Erreur serveur' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ REPARREQUEST sur http://localhost:${PORT}`);
  console.log('   POST /register | POST /login');
  console.log('   POST /forgot-password | POST /change-password');
  console.log('   GET  /users');
  console.log('   CRUD /signalements');
});
