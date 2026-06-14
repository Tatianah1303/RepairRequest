import '../infrastructure/services.dart';

class UserRepository {
  Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String motDePasse,
    required String role,
    String? specialite,
  }) async {
    return await Services.register(
      nom: nom,
      email: email,
      motDePasse: motDePasse,
      role: role,
      specialite: specialite,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    return await Services.login(email: email, motDePasse: motDePasse);
  }

  Future<Map<String, dynamic>> fetchUsers() async {
    return await Services.fetchUsers();
  }
}

class SignalementRepository {
  Future<Map<String, dynamic>> create({
    required String titre,
    required String description,
    required String batiment,
    required String adresse,
    required String quartier,
  }) async {
    return await Services.createSignalement(
      titre: titre,
      description: description,
      batiment: batiment,
      adresse: adresse,
      quartier: quartier,
    );
  }
}

class DiscussionRepository {
  Future<List<Map<String, dynamic>>> load(int signalementId) async {
    return await Services.loadComments(signalementId);
  }

  Future<Map<String, dynamic>> send({
    required String message,
    required int signalementId,
  }) async {
    return await Services.sendComment(
      message: message,
      signalementId: signalementId,
    );
  }
}
