const pool   = require('../../infrastructure/database/db');
const bcrypt = require('bcryptjs');

// Génère un mot de passe temporaire de 8 caractères
function genererMotDePasse() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
  let mdp = '';
  for (let i = 0; i < 8; i++) {
    mdp += chars[Math.floor(Math.random() * chars.length)];
  }
  return mdp;
}

// POST /forgot-password
exports.demanderReset = async (email) => {
  if (!email || email.trim() === '') {
    throw new Error('Email obligatoire');
  }

  const emailClean = email.toLowerCase().trim();

  // Chercher l'utilisateur
  const result = await pool.query(
    'SELECT id_utilisateur, nom, email FROM utilisateurs WHERE LOWER(email) = $1',
    [emailClean]
  );

  // ✅ Si email non trouvé → réponse neutre (sécurité)
  if (result.rows.length === 0) {
    return { found: false, message: 'Si cet email existe, un mot de passe temporaire a été généré.' };
  }

  const user = result.rows[0];

  // Générer mot de passe temporaire
  const nouveauMdp = genererMotDePasse();

  // Hacher et sauvegarder
  const hache = await bcrypt.hash(nouveauMdp, 10);
  await pool.query(
    'UPDATE utilisateurs SET mot_de_passe = $1 WHERE id_utilisateur = $2',
    [hache, user.id_utilisateur]
  );

  return {
    found: true,
    nom:   user.nom,
    email: user.email,
    motDePasseTemporaire: nouveauMdp,
    message: 'Mot de passe temporaire généré avec succès.',
  };
};

// POST /change-password
exports.changerMotDePasse = async ({ email, ancienMdp, nouveauMdp }) => {
  if (!email || !ancienMdp || !nouveauMdp) {
    throw new Error('Tous les champs sont obligatoires');
  }
  if (nouveauMdp.length < 6) {
    throw new Error('Le nouveau mot de passe doit contenir au moins 6 caractères');
  }

  const result = await pool.query(
    'SELECT * FROM utilisateurs WHERE LOWER(email) = $1',
    [email.toLowerCase().trim()]
  );
  if (result.rows.length === 0) throw new Error('Utilisateur introuvable');

  const user = result.rows[0];
  const valide = await bcrypt.compare(ancienMdp, user.mot_de_passe);
  if (!valide) throw new Error('Ancien mot de passe incorrect');

  const hache = await bcrypt.hash(nouveauMdp, 10);
  await pool.query(
    'UPDATE utilisateurs SET mot_de_passe = $1 WHERE id_utilisateur = $2',
    [hache, user.id_utilisateur]
  );

  return { message: 'Mot de passe modifié avec succès' };
};
