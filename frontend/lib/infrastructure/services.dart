import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class Services {
  static Map<String, dynamic>? currentUser;
  static String? authToken;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://192.168.43.93:3000';
    return 'http://localhost:3000';
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    final userStr = prefs.getString('current_user');
    if (userStr != null && userStr.isNotEmpty) {
      try {
        currentUser = jsonDecode(userStr);
      } catch (_) {}
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    authToken = null;
    currentUser = null;
  }

  // ─── AUTH ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String motDePasse,
    required String role,
    String? specialite,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'mot_de_passe': motDePasse,
          'role': role,
          if (specialite != null && specialite.isNotEmpty)
            'specialite': specialite,
        }),
      );
      if (response.statusCode == 201)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'mot_de_passe': motDePasse}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['token'];
        currentUser = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authToken ?? '');
        await prefs.setString('current_user', jsonEncode(currentUser));
        return {'success': true, 'user': data['user'], 'token': data['token']};
      }
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String email,
    required String ancienMdp,
    required String nouveauMdp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'ancienMdp': ancienMdp,
          'nouveauMdp': nouveauMdp,
        }),
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // ─── USERS ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur lors du chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // Récupérer uniquement les techniciens (pour assignation)
  static Future<Map<String, dynamic>> fetchTechniciens() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?role=technicien'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // ─── SIGNALEMENTS ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> createSignalement({
    required String titre,
    required String description,
    required String batiment,
    required String adresse,
    required String quartier,
    String categorie = 'Autre',
    String priorite = 'normal',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signalements'),
        headers: _headers,
        body: jsonEncode({
          'titre': titre,
          'description': description,
          'batiment': batiment,
          'adresse': adresse,
          'quartier': quartier,
          'categorie': categorie,
          'priorite': priorite,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdId = int.tryParse(
          (data['id_signalement'] ?? data['id'] ?? '').toString(),
        );
        return {'success': true, 'data': data, 'createdId': createdId};
      }
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> loadSignalements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signalements'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur lors du chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> getSignalementById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signalements/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Signalement introuvable'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

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
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/signalements/$id'),
        headers: _headers,
        body: jsonEncode({
          'titre': titre,
          'description': description,
          'batiment': batiment,
          'adresse': adresse,
          'quartier': quartier,
          'statut': statut,
          if (categorie != null) 'categorie': categorie,
          if (priorite != null) 'priorite': priorite,
        }),
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur de mise à jour'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // ✅ Technicien prend en charge un signalement
  static Future<Map<String, dynamic>> assignerTechnicien(
    int idSignalement,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/signalements/$idSignalement/assigner'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // ✅ Historique des changements de statut
  static Future<Map<String, dynamic>> getHistorique(int idSignalement) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signalements/$idSignalement/historique'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  static Future<Map<String, dynamic>> deleteSignalement(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/signalements/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Erreur de suppression'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> loadStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signalements/stats'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur stats'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  // ─── COMMENTAIRES ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> loadComments(
    int signalementId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/signalements/$signalementId/commentaires'),
        headers: _headers,
      );
      if (response.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendComment({
    required String message,
    required int signalementId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signalements/$signalementId/commentaires'),
        headers: _headers,
        body: jsonEncode({'contenu': message, 'message': message}),
      );
      if (response.statusCode == 201)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> updateComment({
    required int id,
    required String message,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/signalements/commentaires/$id'),
        headers: _headers,
        body: jsonEncode({'contenu': message, 'message': message}),
      );
      if (response.statusCode == 200)
        return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'message': 'Erreur de mise à jour'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> deleteComment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/signalements/commentaires/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'Erreur de suppression'};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de joindre le serveur.'};
    }
  }

  static String _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['error'] ?? json['message'] ?? 'Erreur inconnue';
    } catch (_) {
      return 'Erreur serveur';
    }
  }
}
