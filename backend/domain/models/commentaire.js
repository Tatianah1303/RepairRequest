/**
 * Modèle Commentaire
 * Représente un commentaire sur un signalement de réparation
 */
class Commentaire {
  constructor({
    id_commentaire,
    message,
    date_commentaire,
    id_signalement,
    id_utilisateur,
    nom_utilisateur,
    role,
  }) {
    this.id_commentaire = id_commentaire;
    this.message = message;
    this.date_commentaire = date_commentaire;
    this.id_signalement = id_signalement;
    this.id_utilisateur = id_utilisateur;
    this.nom_utilisateur = nom_utilisateur;
    this.role = role;
  }

  // Valider les données du commentaire
  static validate(data) {
    if (!data.message || data.message.trim().length === 0) {
      throw new Error('Le message est obligatoire');
    }
    if (!data.id_signalement || data.id_signalement <= 0) {
      throw new Error('Le signalement est obligatoire');
    }
    if (!data.id_utilisateur || data.id_utilisateur <= 0) {
      throw new Error('L\'utilisateur est obligatoire');
    }
    return true;
  }
}

module.exports = Commentaire;
