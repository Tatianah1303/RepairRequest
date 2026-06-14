import 'package:flutter/material.dart';
import '../../application/usecases.dart';
import 'DiscussionPage.dart';
import 'AcceuilPage.dart';

class SignalementPage extends StatefulWidget {
  const SignalementPage({super.key});
  @override
  State<SignalementPage> createState() => _SignalementPageState();
}

class _SignalementPageState extends State<SignalementPage> {
  final titreCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final batimentCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();
  final quartierCtrl = TextEditingController();

  String _categorie = 'Autre';
  String _priorite = 'normal';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Plomberie', 'icon': Icons.water_drop},
    {'label': 'Électricité', 'icon': Icons.electric_bolt},
    {'label': 'Peinture', 'icon': Icons.format_paint},
    {'label': 'Maçonnerie', 'icon': Icons.home_repair_service},
    {'label': 'Menuiserie', 'icon': Icons.door_front_door},
    {'label': 'Climatisation', 'icon': Icons.ac_unit},
    {'label': 'Ascenseur', 'icon': Icons.elevator},
    {'label': 'Toiture', 'icon': Icons.roofing},
    {'label': 'Serrurerie', 'icon': Icons.lock},
    {'label': 'Nettoyage', 'icon': Icons.cleaning_services},
    {'label': 'Autre', 'icon': Icons.build},
  ];

  @override
  void dispose() {
    titreCtrl.dispose();
    descriptionCtrl.dispose();
    batimentCtrl.dispose();
    adresseCtrl.dispose();
    quartierCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (titreCtrl.text.trim().isEmpty ||
        descriptionCtrl.text.trim().isEmpty ||
        batimentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Titre, description et bâtiment sont obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final result = await UseCases.createSignalement(
      titre: titreCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      batiment: batimentCtrl.text.trim(),
      adresse: adresseCtrl.text.trim(),
      quartier: quartierCtrl.text.trim(),
      categorie: _categorie,
      priorite: _priorite,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signalement créé !'),
          backgroundColor: Colors.green,
        ),
      );
      final int? createdId = result['createdId'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => createdId != null
              ? DiscussionPage(signalementId: createdId)
              : const AccueilPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Signalement'),
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
          padding: const EdgeInsets.all(18),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.report_problem_outlined,
                    color: Color(0xFF6A1B9A),
                    size: 40,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Déclarer un problème',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _field(titreCtrl, 'Titre *', Icons.title),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionCtrl,
                    maxLines: 3,
                    decoration: _deco(
                      'Description *',
                      Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(batimentCtrl, 'Bâtiment *', Icons.apartment),
                  const SizedBox(height: 12),
                  _field(adresseCtrl, 'Adresse', Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _field(quartierCtrl, 'Quartier', Icons.map_outlined),
                  const SizedBox(height: 16),

                  // ✅ Catégorie
                  const Text(
                    'Catégorie du problème',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final sel = _categorie == cat['label'];
                      return GestureDetector(
                        onTap: () => setState(() => _categorie = cat['label']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF6A1B9A)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 15,
                                color: sel ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                cat['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sel ? Colors.white : Colors.black87,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Priorité
                  const Text(
                    'Priorité',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _prioriteBtn('urgent', '🔴 Urgent', Colors.red),
                      const SizedBox(width: 8),
                      _prioriteBtn('normal', '🟠 Normal', Colors.orange),
                      const SizedBox(width: 8),
                      _prioriteBtn('faible', '🟢 Faible', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _envoyer,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isLoading ? 'Envoi...' : 'Envoyer le signalement',
                        style: const TextStyle(
                          fontSize: 15,
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

  Widget _prioriteBtn(String val, String label, Color color) {
    final sel = _priorite == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priorite = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: sel ? 2 : 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: sel ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) =>
      TextField(controller: ctrl, decoration: _deco(label, icon));

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
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
