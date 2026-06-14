/**
 * Modèle User
 * Représente un utilisateur du système
 */
class User {
  constructor({
    id_utilisateur,
    nom,
    email,
    mot_de_passe,
    role,
    specialite,
    date_creation,
  }) {
    this.id_utilisateur = id_utilisateur;
    this.nom = nom;
    this.email = email;
    this.mot_de_passe = mot_de_passe;
    this.role = role || 'resident';
    this.specialite = specialite;
    this.date_creation = date_creation;
  }

  // Valider les données de l'utilisateur
  static validate(data) {
    if (!data.nom || data.nom.trim().length === 0) {
      throw new Error('Le nom est obligatoire');
    }
    if (!data.email || !this.isValidEmail(data.email)) {
      throw new Error('L\'email est invalide');
    }
    if (!data.mot_de_passe || data.mot_de_passe.length < 6) {
      throw new Error('Le mot de passe doit contenir au moins 6 caractères');
    }
    if (!data.role || !Object.values(User.ROLES).includes(data.role)) {
      throw new Error('Le rôle est invalide');
    }
    return true;
  }

  // Valider un email
  static isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // Rôles valides
  static ROLES = {
    RESIDENT: 'resident',
    TECHNICIEN: 'technicien',
    ADMIN: 'admin',
  };
}

module.exports = User;
