import 'package:flutter/material.dart';
import '../../application/usecases.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    final result = await UseCases.loadUsers();
    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        users = List<Map<String, dynamic>>.from(result['data']);
        if (users.isEmpty) message = 'Aucun utilisateur trouvé.';
      } else {
        message = result['message'] ?? 'Erreur lors du chargement.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        backgroundColor: const Color(0xFF6A1B9A), // violet élégant
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // bouton retour vers Accueil
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                height: 40, // logo petit et rond
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFEDE7F6),
            ], // bleu clair → violet doux
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
            ? Center(
                child: Text(
                  message.isNotEmpty ? message : 'Aucune donnée disponible.',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final user = users[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user['role'] == 'technicien'
                            ? Colors.orange
                            : user['role'] == 'admin'
                            ? Colors.red
                            : Colors.green,
                        child: Text(
                          user['nom'] != null && user['nom'].isNotEmpty
                              ? user['nom'][0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user['nom'] ?? 'Utilisateur'),
                      subtitle: Text(
                        "${user['email'] ?? '—'} • ${user['role'] ?? '—'}",
                      ),
                      trailing: user['specialite'] != null
                          ? Text(
                              user['specialite'],
                              style: const TextStyle(color: Colors.black54),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
