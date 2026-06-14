import 'package:flutter/material.dart';
import '../../application/usecases.dart';
import '../../infrastructure/services.dart';
import 'ConnexionPage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ancienMdpCtrl = TextEditingController();
  final nouveauMdpCtrl = TextEditingController();
  final confirmMdpCtrl = TextEditingController();
  bool obscure1 = true, obscure2 = true, obscure3 = true;
  bool isLoading = false;
  bool showChangeMdp = false;

  Map<String, dynamic>? get user => Services.currentUser;
  String get role => user?['role'] ?? '';

  Color get roleColor {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'technicien':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData get roleIcon {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'technicien':
        return Icons.engineering;
      default:
        return Icons.person;
    }
  }

  @override
  void dispose() {
    ancienMdpCtrl.dispose();
    nouveauMdpCtrl.dispose();
    confirmMdpCtrl.dispose();
    super.dispose();
  }

  Future<void> _changerMotDePasse() async {
    if (ancienMdpCtrl.text.isEmpty || nouveauMdpCtrl.text.isEmpty) {
      _erreur('Tous les champs sont obligatoires');
      return;
    }
    if (nouveauMdpCtrl.text != confirmMdpCtrl.text) {
      _erreur('Les nouveaux mots de passe ne correspondent pas');
      return;
    }
    if (nouveauMdpCtrl.text.length < 6) {
      _erreur('Minimum 6 caractères');
      return;
    }

    setState(() => isLoading = true);
    final result = await UseCases.changePassword(
      email: user?['email'] ?? '',
      ancienMdp: ancienMdpCtrl.text,
      nouveauMdp: nouveauMdpCtrl.text,
    );
    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mot de passe changé ! Reconnectez-vous.'),
          backgroundColor: Colors.green,
        ),
      );
      await UseCases.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ConnexionPage()),
        (_) => false,
      );
    } else {
      _erreur(result['message'] ?? 'Erreur');
    }
  }

  void _erreur(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F9FF), Color(0xFFEDE7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar + infos
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: roleColor.withOpacity(0.15),
                        child: Icon(roleIcon, size: 42, color: roleColor),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?['nom'] ?? 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(roleIcon, color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user?['specialite'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Spécialité : ${user!['specialite']}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Changer mot de passe
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF6A1B9A),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Changer le mot de passe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: showChangeMdp,
                            activeColor: const Color(0xFF6A1B9A),
                            onChanged: (v) => setState(() => showChangeMdp = v),
                          ),
                        ],
                      ),
                      if (showChangeMdp) ...[
                        const SizedBox(height: 16),
                        _mdpField(
                          ancienMdpCtrl,
                          'Ancien mot de passe',
                          obscure1,
                          () => setState(() => obscure1 = !obscure1),
                        ),
                        const SizedBox(height: 12),
                        _mdpField(
                          nouveauMdpCtrl,
                          'Nouveau mot de passe',
                          obscure2,
                          () => setState(() => obscure2 = !obscure2),
                        ),
                        const SizedBox(height: 12),
                        _mdpField(
                          confirmMdpCtrl,
                          'Confirmer le nouveau',
                          obscure3,
                          () => setState(() => obscure3 = !obscure3),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : _changerMotDePasse,
                            icon: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              isLoading
                                  ? 'Sauvegarde...'
                                  : 'Changer le mot de passe',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mdpField(
    TextEditingController ctrl,
    String label,
    bool obs,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: obs,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6A1B9A)),
        suffixIcon: IconButton(
          icon: Icon(obs ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
