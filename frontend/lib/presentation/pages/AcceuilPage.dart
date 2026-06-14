import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../application/usecases.dart';
import '../../infrastructure/services.dart';
import 'SignalementPage.dart';
import 'SignalementsListPage.dart';
import 'UsersPage.dart';
import 'DeconnexionPage.dart';
import 'ProfilPage.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});
  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  double enAttente = 0, enCours = 0, refuse = 0, termine = 0;
  int total = 0;
  bool isLoading = true;
  int touchedIndex = -1;

  String get userName => Services.currentUser?['nom'] ?? 'Utilisateur';
  String get userRole => Services.currentUser?['role'] ?? '';
  bool get isAdmin => userRole == 'admin';
  bool get isResident => userRole == 'resident';
  bool get isTechnicien => userRole == 'technicien';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    final result = await UseCases.loadStats();
    if (mounted && result['success'] == true) {
      final data = result['data'];
      setState(() {
        enAttente = double.tryParse(data['enAttente'].toString()) ?? 0;
        enCours = double.tryParse(data['enCours'].toString()) ?? 0;
        refuse = double.tryParse(data['refuse'].toString()) ?? 0;
        termine = double.tryParse(data['termine'].toString()) ?? 0;
        total = int.tryParse(data['total']?.toString() ?? '0') ?? 0;
        isLoading = false;
      });
    } else if (mounted)
      setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REPARREQUEST'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Mon profil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Déconnexion',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeconnexionPage()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F9FF), Color(0xFFEDE7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bandeau bienvenue
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.waving_hand,
                        color: Colors.amber,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, $userName !',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (total > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$total signalement${total > 1 ? "s" : ""}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isLoading
                        ? const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : (enAttente + enCours + refuse + termine == 0)
                        ? const SizedBox(
                            height: 180,
                            child: Center(
                              child: Text(
                                'Aucune donnée',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (e, r) => setState(
                                        () => touchedIndex =
                                            r
                                                ?.touchedSection
                                                ?.touchedSectionIndex ??
                                            -1,
                                      ),
                                    ),
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 30,
                                    sections: [
                                      _section(
                                        0,
                                        enAttente,
                                        Colors.red,
                                        'Attente',
                                      ),
                                      _section(
                                        1,
                                        enCours,
                                        Colors.orange,
                                        'En cours',
                                      ),
                                      _section(
                                        2,
                                        refuse,
                                        Colors.grey,
                                        'Refusé',
                                      ),
                                      _section(
                                        3,
                                        termine,
                                        Colors.green,
                                        'Terminé',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 14,
                                runSpacing: 6,
                                children: [
                                  _legende(Colors.red, 'En attente', enAttente),
                                  _legende(Colors.orange, 'En cours', enCours),
                                  _legende(Colors.grey, 'Refusé', refuse),
                                  _legende(Colors.green, 'Terminé', termine),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _counter('En attente', enAttente.toInt(), Colors.red),
                    const SizedBox(width: 8),
                    _counter('En cours', enCours.toInt(), Colors.orange),
                    const SizedBox(width: 8),
                    _counter('Terminé', termine.toInt(), Colors.green),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    if (isResident)
                      _actionCard(
                        'Nouveau Signalement',
                        Icons.add_circle_outline,
                        const Color(0xFF6A1B9A),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignalementPage(),
                          ),
                        ).then((_) => _loadStats()),
                      ),
                    _actionCard(
                      isTechnicien
                          ? 'Signalements à traiter'
                          : 'Mes Signalements',
                      Icons.list_alt_outlined,
                      const Color(0xFFF57C00),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignalementsListPage(),
                        ),
                      ).then((_) => _loadStats()),
                    ),
                    if (isAdmin)
                      _actionCard(
                        'Utilisateurs',
                        Icons.people_outline,
                        Colors.teal,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UsersPage()),
                        ),
                      ),
                    _actionCard(
                      'Mon Profil',
                      Icons.account_circle_outlined,
                      Colors.indigo,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilPage()),
                      ),
                    ),
                    _actionCard(
                      'Actualiser',
                      Icons.refresh,
                      Colors.blueGrey,
                      _loadStats,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section(int i, double val, Color color, String label) {
    final t = i == touchedIndex;
    return PieChartSectionData(
      value: val,
      color: color,
      title: '${val.toStringAsFixed(0)}%',
      radius: t ? 85 : 70,
      titleStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: t ? 13 : 10,
      ),
    );
  }

  Widget _legende(Color color, String label, double val) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        '$label ${val.toStringAsFixed(0)}%',
        style: const TextStyle(fontSize: 12),
      ),
    ],
  );

  Widget _counter(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    ),
  );

  Widget _actionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
