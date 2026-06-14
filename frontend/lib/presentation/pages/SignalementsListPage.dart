import 'package:flutter/material.dart';
import '../../application/usecases.dart';
import '../../infrastructure/services.dart';
import 'SignalementPage.dart';
import 'DiscussionPage.dart';
import 'EditSignalementPage.dart';

class SignalementsListPage extends StatefulWidget {
  const SignalementsListPage({super.key});
  @override
  State<SignalementsListPage> createState() => _SignalementsListPageState();
}

class _SignalementsListPageState extends State<SignalementsListPage> {
  List<Map<String, dynamic>> signalements = [];
  List<Map<String, dynamic>> filtres = [];
  bool isLoading = true;
  String filtreStatut = 'tous';

  String get role => Services.currentUser?['role'] ?? 'resident';
  bool get isTechnicien => role == 'technicien';
  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final result = await UseCases.loadSignalements();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        final raw = result['data'];
        final list = raw is List
            ? raw
            : (raw['signalements'] ?? raw['data'] ?? []);
        signalements = List<Map<String, dynamic>>.from(list);
        _appliquerFiltre();
      }
    });
  }

  void _appliquerFiltre() {
    setState(() {
      filtres = filtreStatut == 'tous'
          ? List.from(signalements)
          : signalements.where((s) => s['statut'] == filtreStatut).toList();
    });
  }

  Future<void> _supprimer(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce signalement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final r = await UseCases.deleteSignalement(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            r['success'] == true
                ? 'Signalement supprimé'
                : r['message'] ?? 'Erreur',
          ),
          backgroundColor: r['success'] == true ? Colors.green : Colors.red,
        ),
      );
      if (r['success'] == true) _load();
    }
  }

  Color _statutColor(String? s) {
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

  IconData _prioriteIcon(String? p) {
    switch (p) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'faible':
        return Icons.low_priority;
      default:
        return Icons.remove;
    }
  }

  Color _prioriteColor(String? p) {
    switch (p) {
      case 'urgent':
        return Colors.red;
      case 'faible':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTechnicien ? 'Signalements à traiter' : 'Mes Signalements',
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
        child: Column(
          children: [
            // Filtres
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        'tous',
                        'en attente',
                        'en cours',
                        'refusé',
                        'terminé',
                      ].map((s) {
                        final sel = filtreStatut == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              s == 'tous' ? 'Tous (${signalements.length})' : s,
                              style: TextStyle(
                                color: sel ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                            selected: sel,
                            selectedColor: s == 'tous'
                                ? const Color(0xFF6A1B9A)
                                : _statutColor(s),
                            backgroundColor: Colors.grey.shade100,
                            onSelected: (_) {
                              setState(() => filtreStatut = s);
                              _appliquerFiltre();
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    '${filtres.length} signalement(s)',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtres.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 56,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            filtreStatut == 'tous'
                                ? 'Aucun signalement'
                                : 'Aucun "$filtreStatut"',
                            style: const TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                        itemCount: filtres.length,
                        itemBuilder: (_, i) => _buildCard(filtres[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // ✅ Résident seulement peut créer un signalement
      floatingActionButton: isResident
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignalementPage()),
              ).then((_) => _load()),
            )
          : null,
    );
  }

  Widget _buildCard(Map<String, dynamic> sig) {
    final statut = sig['statut'] ?? '';
    final priorite = sig['priorite'] ?? 'normal';
    final technicien = sig['nom_technicien'];
    final id = sig['id_signalement'] ?? sig['id'] ?? 0;
    final color = _statutColor(statut);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _prioriteIcon(priorite),
                color: _prioriteColor(priorite),
                size: 20,
              ),
            ],
          ),
          title: Text(
            sig['titre'] ?? 'Sans titre',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statut.isEmpty ? 'N/A' : statut,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                if (technicien != null) ...[
                  const Icon(Icons.engineering, size: 13, color: Colors.orange),
                  const SizedBox(width: 3),
                  Text(
                    technicien,
                    style: const TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ] else ...[
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: Colors.black38,
                  ),
                  Expanded(
                    child: Text(
                      sig['quartier'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _infoRow(
                    Icons.description_outlined,
                    'Description',
                    sig['description'] ?? '',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.apartment,
                    'Bâtiment',
                    sig['batiment'] ?? 'N/A',
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Adresse',
                    sig['adresse'] ?? 'N/A',
                  ),
                  if (sig['categorie'] != null) ...[
                    const SizedBox(height: 4),
                    _infoRow(
                      Icons.category_outlined,
                      'Catégorie',
                      sig['categorie'],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Discussion — tout le monde
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6A1B9A),
                            side: const BorderSide(color: Color(0xFF6A1B9A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: const Text(
                            'Discussion',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiscussionPage(signalementId: id),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ✅ Éditer : résident voit "Éditer infos", technicien voit "Changer statut"
                      if (!isTechnicien || isTechnicien)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(
                              isTechnicien ? Icons.update : Icons.edit_outlined,
                              size: 16,
                            ),
                            label: Text(
                              isTechnicien ? 'Statut' : 'Éditer',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () =>
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditSignalementPage(signalement: sig),
                                  ),
                                ).then((ok) {
                                  if (ok == true) _load();
                                }),
                          ),
                        ),
                      const SizedBox(width: 8),

                      // ✅ Supprimer : CACHÉ pour technicien
                      if (!isTechnicien)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                          ),
                          onPressed: () => _supprimer(id),
                          child: const Icon(Icons.delete_outline, size: 18),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6A1B9A)),
        const SizedBox(width: 6),
        Text(
          '$label : ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
