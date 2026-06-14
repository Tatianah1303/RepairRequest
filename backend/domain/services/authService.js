const bcrypt = require('bcryptjs');
const pool = require('../../infrastructure/database/db');
const { generateToken } = require('../../infrastructure/security/jwt');

exports.register = async ({ nom, email, mot_de_passe, role, specialite }) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error("L'email n'est pas valide");
  }

  const existingUser = await pool.query(
    'SELECT id_utilisateur FROM utilisateurs WHERE email = $1',
    [email]
  );
  if (existingUser.rows.length > 0) {
    throw new Error('Cet email est déjà utilisé');
  }

  const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
  const userSpecialite = role === 'technicien' ? specialite : null;

  const result = await pool.query(
    `INSERT INTO utilisateurs (nom, email, mot_de_passe, role, specialite, date_creation)
     VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
     RETURNING id_utilisateur, nom, email, role, specialite`,
    [nom, email, hashedPassword, role || 'resident', userSpecialite]
  );
  return result.rows[0];
};

exports.login = async ({ email, mot_de_passe }) => {
  const result = await pool.query(
    'SELECT * FROM utilisateurs WHERE email = $1',
    [email]
  );
  if (result.rows.length === 0) {
    throw new Error('Aucun utilisateur trouvé avec cet email');
  }

  const user = result.rows[0];
  const validPassword = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
  if (!validPassword) {
    throw new Error('Le mot de passe est incorrect');
  }

  const token = generateToken({ id: user.id_utilisateur, role: user.role });

  // ✅ Ne jamais renvoyer le mot de passe au client
  const safeUser = {
    id_utilisateur: user.id_utilisateur,
    nom: user.nom,
    email: user.email,
    role: user.role,
    specialite: user.specialite,
    date_creation: user.date_creation,
  };

  return { token, user: safeUser };
};

/*const bcrypt = require('bcryptjs');
const pool = require('../../infrastructure/database/db');
const { generateToken } = require('../../infrastructure/security/jwt');

exports.register = async ({ nom, email, mot_de_passe, role, specialite }) => {
  // Valider l'email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error('L\'email n\'est pas valide');
  }

  // Vérifier si l'email existe déjà
  const existingUser = await pool.query(
    'SELECT id_utilisateur FROM utilisateurs WHERE email = $1',
    [email]
  );
  
  if (existingUser.rows.length > 0) {
    throw new Error('Cet email est déjà utilisé');
  }

  const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
  const userSpecialite = role === 'technicien' ? specialite : null;
  const result = await pool.query(
    `INSERT INTO utilisateurs (nom, email, mot_de_passe, role, specialite, date_creation)
     VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
     RETURNING id_utilisateur, nom, email, role, specialite`,
    [nom, email, hashedPassword, role || 'resident', userSpecialite]
  );
  return result.rows[0];
};

exports.login = async ({ email, mot_de_passe }) => {
  const result = await pool.query('SELECT * FROM utilisateurs WHERE email = $1', [email]);
  if (result.rows.length === 0) {
    throw new Error('Aucun utilisateur trouvé avec cet email');
  }

  const user = result.rows[0];
  const validPassword = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
  if (!validPassword) {
    throw new Error('Le mot de passe est incorrect');
  }

  const token = generateToken({ id: user.id_utilisateur, role: user.role });
  return { token, user };
};*/
