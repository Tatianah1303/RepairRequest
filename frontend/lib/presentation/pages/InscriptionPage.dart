import 'package:flutter/material.dart';
import '../../application/usecases.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final motdepasseController = TextEditingController();
  String role = 'resident';
  String? specialiteChoisie;
  bool obscure = true;
  bool isLoading = false;

  // ✅ Liste des spécialités prédéfinies pour les techniciens
  final List<String> specialites = [
    'Plomberie',
    'Électricité',
    'Peinture',
    'Maçonnerie',
    'Menuiserie',
    'Climatisation / Ventilation',
    'Ascenseur',
    'Toiture / Étanchéité',
    'Serrurerie',
    'Nettoyage / Entretien',
  ];

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    motdepasseController.dispose();
    super.dispose();
  }

  Future<void> inscrire() async {
    if (nomController.text.trim().isEmpty) {
      _erreur('Le nom est obligatoire');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      _erreur("L'email est obligatoire");
      return;
    }
    if (motdepasseController.text.length < 6) {
      _erreur('Mot de passe : 6 caractères minimum');
      return;
    }
    if (role == 'technicien' && specialiteChoisie == null) {
      _erreur('Veuillez choisir une spécialité');
      return;
    }

    setState(() => isLoading = true);

    final result = await UseCases.registerUser(
      nom: nomController.text.trim(),
      email: emailController.text.trim(),
      motDePasse: motdepasseController.text,
      role: role,
      specialite: role == 'technicien' ? specialiteChoisie : null,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      _erreur(result['message'] ?? "Erreur d'inscription");
    }
  }

  void _erreur(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(
                    Icons.person_add,
                    color: Color(0xFF6A1B9A),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nom
                  _field(nomController, 'Nom complet', Icons.person_outline),
                  const SizedBox(height: 14),

                  // Email
                  _field(
                    emailController,
                    'Email',
                    Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Mot de passe
                  TextField(
                    controller: motdepasseController,
                    obscureText: obscure,
                    decoration:
                        _deco(
                          'Mot de passe (min. 6 caractères)',
                          Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                  ),
                  const SizedBox(height: 14),

                  // Rôle
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: _deco('Rôle', Icons.badge_outlined),
                    items: const [
                      DropdownMenuItem(
                        value: 'resident',
                        child: Text('🏠  Résident'),
                      ),
                      DropdownMenuItem(
                        value: 'technicien',
                        child: Text('🔧  Technicien'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('👑  Administrateur'),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      role = v ?? 'resident';
                      specialiteChoisie =
                          null; // reset spécialité si rôle change
                    }),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Spécialité avec dropdown prédéfini (visible uniquement pour technicien)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: role == 'technicien'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bandeau info technicien
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.4),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'En tant que technicien, choisissez votre domaine de spécialisation.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Dropdown spécialités
                              DropdownButtonFormField<String>(
                                value: specialiteChoisie,
                                decoration: _deco(
                                  'Spécialité *',
                                  Icons.build_outlined,
                                ),
                                hint: const Text('Choisir une spécialité'),
                                items: specialites
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => specialiteChoisie = v),
                              ),
                              const SizedBox(height: 14),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Bouton S'inscrire
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading ? null : inscrire,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: _deco(label, icon),
    );
  }

  InputDecoration _deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
