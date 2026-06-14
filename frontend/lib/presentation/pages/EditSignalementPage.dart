import 'package:flutter/material.dart';
import '../../application/usecases.dart';
import '../../infrastructure/services.dart';

class EditSignalementPage extends StatefulWidget {
  final Map<String, dynamic> signalement;
  const EditSignalementPage({super.key, required this.signalement});
  @override
  State<EditSignalementPage> createState() => _EditSignalementPageState();
}

class _EditSignalementPageState extends State<EditSignalementPage> {
  late TextEditingController titreCtrl;
  late TextEditingController descCtrl;
  late TextEditingController batimentCtrl;
  late TextEditingController adresseCtrl;
  late TextEditingController quartierCtrl;
  late String statut;
  bool isLoading = false;

  // Rôle de l'utilisateur connecté
  String get role => Services.currentUser?['role'] ?? 'resident';
  bool get isTechnicien => role == 'technicien';
  bool get isAdmin => role == 'admin';

  final List<String> statuts = ['en attente', 'en cours', 'refusé', 'terminé'];

  @override
  void initState() {
    super.initState();
    final s = widget.signalement;
    titreCtrl = TextEditingController(text: s['titre'] ?? '');
    descCtrl = TextEditingController(text: s['description'] ?? '');
    batimentCtrl = TextEditingController(text: s['batiment'] ?? '');
    adresseCtrl = TextEditingController(text: s['adresse'] ?? '');
    quartierCtrl = TextEditingController(text: s['quartier'] ?? '');
    statut = s['statut'] ?? 'en attente';
  }

  @override
  void dispose() {
    titreCtrl.dispose();
    descCtrl.dispose();
    batimentCtrl.dispose();
    adresseCtrl.dispose();
    quartierCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    setState(() => isLoading = true);

    final id =
        widget.signalement['id_signalement'] ?? widget.signalement['id'] ?? 0;

    Map<String, dynamic> result;

    if (isTechnicien) {
      // ✅ Technicien : envoie SEULEMENT le statut
      result = await UseCases.updateSignalement(
        id: id,
        titre: widget.signalement['titre'] ?? '',
        description: widget.signalement['description'] ?? '',
        batiment: widget.signalement['batiment'] ?? '',
        adresse: widget.signalement['adresse'] ?? '',
        quartier: widget.signalement['quartier'] ?? '',
        statut: statut,
      );
    } else {
      // ✅ Résident / Admin : envoie toutes les infos
      result = await UseCases.updateSignalement(
        id: id,
        titre: titreCtrl.text.trim(),
        description: descCtrl.text.trim(),
        batiment: batimentCtrl.text.trim(),
        adresse: adresseCtrl.text.trim(),
        quartier: quartierCtrl.text.trim(),
        statut: isAdmin ? statut : widget.signalement['statut'] ?? 'en attente',
      );
    }

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signalement mis à jour ✅'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _statutColor(String s) {
    switch (s) {
      case 'en attente':
        return Colors.red;
      case 'en cours':
        return Colors.orange;
      case 'refusé':
        return Colors.grey;
      case 'terminé':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTechnicien ? 'Changer le statut' : 'Éditer le signalement',
        ),
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
                  // ─── Bandeau rôle ───
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isTechnicien
                          ? Colors.orange.withOpacity(0.1)
                          : const Color(0xFF6A1B9A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isTechnicien
                            ? Colors.orange.withOpacity(0.4)
                            : const Color(0xFF6A1B9A).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isTechnicien
                              ? Icons.engineering
                              : Icons.person_outline,
                          color: isTechnicien
                              ? Colors.orange
                              : const Color(0xFF6A1B9A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isTechnicien
                                ? 'Mode Technicien : vous pouvez uniquement modifier le statut'
                                : isAdmin
                                ? 'Mode Admin : vous pouvez tout modifier'
                                : 'Mode Résident : vous pouvez modifier les informations du signalement',
                            style: TextStyle(
                              fontSize: 12,
                              color: isTechnicien
                                  ? Colors.orange
                                  : const Color(0xFF6A1B9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ─── Champs infos (résident + admin seulement) ───
                  if (!isTechnicien) ...[
                    _field(titreCtrl, 'Titre *', Icons.title),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
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
                    const SizedBox(height: 18),
                  ],

                  // ─── Statut (technicien + admin) ───
                  if (isTechnicien || isAdmin) ...[
                    const Text(
                      'Statut du signalement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Boutons statut visuels
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.8,
                      children: statuts.map((s) {
                        final sel = statut == s;
                        return GestureDetector(
                          onTap: () => setState(() => statut = s),
                          child: Container(
                            decoration: BoxDecoration(
                              color: sel ? _statutColor(s) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _statutColor(s),
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: sel ? Colors.white : _statutColor(s),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ─── Bouton sauvegarder ───
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
                      onPressed: isLoading ? null : _sauvegarder,
                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        isLoading ? 'Sauvegarde...' : 'Sauvegarder',
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
