/**
 * Modèle Signalement
 * Représente une demande de signalement de réparation
 */
class Signalement {
  constructor({
    id_signalement,
    titre,
    description,
    batiment,
    adresse,
    quartier,
    statut,
    date_signalement,
    id_utilisateur,
  }) {
    this.id_signalement = id_signalement;
    this.titre = titre;
    this.description = description;
    this.batiment = batiment;
    this.adresse = adresse;
    this.quartier = quartier;
    this.statut = statut || 'en attente';
    this.date_signalement = date_signalement;
    this.id_utilisateur = id_utilisateur;
  }

  // Valider les données du signalement
  static validate(data) {
    if (!data.titre || data.titre.trim().length === 0) {
      throw new Error('Le titre est obligatoire');
    }
    if (!data.description || data.description.trim().length === 0) {
      throw new Error('La description est obligatoire');
    }
    if (!data.batiment || data.batiment.trim().length === 0) {
      throw new Error('Le bâtiment est obligatoire');
    }
    if (!data.adresse || data.adresse.trim().length === 0) {
      throw new Error('L\'adresse est obligatoire');
    }
    if (!data.quartier || data.quartier.trim().length === 0) {
      throw new Error('Le quartier est obligatoire');
    }
    return true;
  }

  // Statuts valides
  static STATUTS = {
    EN_ATTENTE: 'en attente',
    EN_COURS: 'en cours',
    REFUSE: 'refusé',
    TERMINE: 'terminé',
  };
}

module.exports = Signalement;
