import '../infrastructure/services.dart';

class UseCases {
  // 🔐 Auth
  static Future<Map<String, dynamic>> registerUser({
    required String nom,
    required String email,
    required String motDePasse,
    required String role,
    String? specialite,
  }) => Services.register(
    nom: nom,
    email: email,
    motDePasse: motDePasse,
    role: role,
    specialite: specialite,
  );

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String motDePasse,
  }) => Services.login(email: email, motDePasse: motDePasse);

  static Future<void> logout() => Services.clearSession();

  static Future<Map<String, dynamic>> forgotPassword({required String email}) =>
      Services.forgotPassword(email: email);

  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String ancienMdp,
    required String nouveauMdp,
  }) => Services.changePassword(
    email: email,
    ancienMdp: ancienMdp,
    nouveauMdp: nouveauMdp,
  );

  // 🏢 Signalements
  static Future<Map<String, dynamic>> createSignalement({
    required String titre,
    required String description,
    required String batiment,
    required String adresse,
    required String quartier,
    String categorie = 'Autre',
    String priorite = 'normal',
  }) => Services.createSignalement(
    titre: titre,
    description: description,
    batiment: batiment,
    adresse: adresse,
    quartier: quartier,
    categorie: categorie,
    priorite: priorite,
  );

  static Future<Map<String, dynamic>> loadSignalements() =>
      Services.loadSignalements();
  static Future<Map<String, dynamic>> getSignalementById(int id) =>
      Services.getSignalementById(id);

  static Future<Map<String, dynamic>> updateSignalement({
    required int id,
    required String titre,
    required String description,
    required String batiment,
    required String adresse,
    required String quartier,
    required String statut,
    String? categorie,
    String? priorite,
  }) => Services.updateSignalement(
    id: id,
    titre: titre,
    description: description,
    batiment: batiment,
    adresse: adresse,
    quartier: quartier,
    statut: statut,
    categorie: categorie,
    priorite: priorite,
  );

  static Future<Map<String, dynamic>> deleteSignalement(int id) =>
      Services.deleteSignalement(id);
  static Future<Map<String, dynamic>> loadStats() => Services.loadStats();

  // ✅ Technicien prend en charge
  static Future<Map<String, dynamic>> assignerTechnicien(int id) =>
      Services.assignerTechnicien(id);

  // ✅ Historique statuts
  static Future<Map<String, dynamic>> getHistorique(int id) =>
      Services.getHistorique(id);

  // 💬 Commentaires
  static Future<Map<String, dynamic>> getCommentaires(int signalementId) async {
    final data = await Services.loadComments(signalementId);
    return {'success': true, 'data': data};
  }

  static Future<Map<String, dynamic>> addCommentaire({
    required int idSignalement,
    required String contenu,
  }) => Services.sendComment(message: contenu, signalementId: idSignalement);

  static Future<Map<String, dynamic>> updateCommentaire({
    required int id,
    required String contenu,
  }) => Services.updateComment(id: id, message: contenu);

  static Future<Map<String, dynamic>> deleteCommentaire(int id) =>
      Services.deleteComment(id);

  // 👥 Utilisateurs
  static Future<Map<String, dynamic>> loadUsers() => Services.fetchUsers();
  static Future<Map<String, dynamic>> loadTechniciens() =>
      Services.fetchTechniciens();
}
