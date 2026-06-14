class User {
  final int id;
  final String nom;
  final String email;
  final String role;
  final String? specialite;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.specialite,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id_utilisateur'],
    nom: json['nom'],
    email: json['email'],
    role: json['role'],
    specialite: json['specialite'],
  );
}

class Signalement {
  final int id;
  final String titre;
  final String description;
  final String batiment;
  final String adresse;
  final String quartier;
  final String statut;
  final DateTime dateSignalement;

  Signalement({
    required this.id,
    required this.titre,
    required this.description,
    required this.batiment,
    required this.adresse,
    required this.quartier,
    required this.statut,
    required this.dateSignalement,
  });

  factory Signalement.fromJson(Map<String, dynamic> json) => Signalement(
    id: json['id_signalement'],
    titre: json['titre'],
    description: json['description'],
    batiment: json['batiment'],
    adresse: json['adresse'],
    quartier: json['quartier'],
    statut: json['statut'],
    dateSignalement: DateTime.parse(json['date_signalement']),
  );
}

class Commentaire {
  final int id;
  final String message;
  final String date;
  final String nomUtilisateur;
  final String role;
  final int idUtilisateur;

  Commentaire({
    required this.id,
    required this.message,
    required this.date,
    required this.nomUtilisateur,
    required this.role,
    required this.idUtilisateur,
  });

  factory Commentaire.fromJson(Map<String, dynamic> json) => Commentaire(
    id: json['id_commentaire'],
    message: json['message'],
    date: json['date_commentaire'],
    nomUtilisateur: json['nom_utilisateur'],
    role: json['role'],
    idUtilisateur: json['id_utilisateur'],
  );
}
