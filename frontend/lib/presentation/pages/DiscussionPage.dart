import 'package:flutter/material.dart';
import '../../application/usecases.dart';
import '../../infrastructure/services.dart';

class DiscussionPage extends StatefulWidget {
  final int signalementId;
  const DiscussionPage({super.key, required this.signalementId});
  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  Map<String, dynamic>? signalementData;
  final messageCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  List<Map<String, dynamic>> commentaires = [];
  List<Map<String, dynamic>> historique = [];
  bool isLoading = true;
  bool isSending = false;
  int? editingId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadSignalement(),
      _loadCommentaires(),
      _loadHistorique(),
    ]);
  }

  Future<void> _loadSignalement() async {
    final r = await UseCases.getSignalementById(widget.signalementId);
    if (mounted && r['success'] == true)
      setState(() {
        signalementData = r['data'];
        isLoading = false;
      });
    else if (mounted)
      setState(() => isLoading = false);
  }

  Future<void> _loadCommentaires() async {
    final r = await UseCases.getCommentaires(widget.signalementId);
    if (mounted && r['success'] == true) {
      final raw = r['data'];
      final list = raw is List ? raw : (raw['data'] ?? []);
      setState(() {
        commentaires = List<Map<String, dynamic>>.from(list);
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadHistorique() async {
    final r = await UseCases.getHistorique(widget.signalementId);
    if (mounted && r['success'] == true) {
      setState(() {
        historique = List<Map<String, dynamic>>.from(r['data'] ?? []);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _envoyer() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => isSending = true);
    if (editingId != null) {
      final r = await UseCases.updateCommentaire(id: editingId!, contenu: text);
      if (mounted && r['success'] == true) {
        messageCtrl.clear();
        editingId = null;
        await _loadCommentaires();
      }
    } else {
      final r = await UseCases.addCommentaire(
        idSignalement: widget.signalementId,
        contenu: text,
      );
      if (mounted) {
        if (r['success'] == true) {
          messageCtrl.clear();
          await _loadCommentaires();
        } else
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(r['message'] ?? 'Erreur'),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
    if (mounted) setState(() => isSending = false);
  }

  Future<void> _supprimerCommentaire(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce commentaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await UseCases.deleteCommentaire(id);
      if (mounted) await _loadCommentaires();
    }
  }

  // ✅ Technicien prend en charge
  Future<void> _prendreEnCharge() async {
    final r = await UseCases.assignerTechnicien(widget.signalementId);
    if (!mounted) return;
    if (r['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signalement pris en charge !'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadAll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r['message'] ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool get _isTechnicienOuAdmin {
    final role = Services.currentUser?['role'] ?? '';
    return role == 'technicien' || role == 'admin';
  }

  bool _isMyComment(Map<String, dynamic> c) {
    final myId =
        Services.currentUser?['id_utilisateur'] ?? Services.currentUser?['id'];
    return myId != null && c['id_utilisateur'] == myId;
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

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final statut = signalementData?['statut'] ?? '';
    final priorite = signalementData?['priorite'] ?? 'normal';
    final categorie = signalementData?['categorie'] ?? '';
    final technicien = signalementData?['nom_technicien'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: signalementData == null
            ? const Text('Discussion')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signalementData!['titre'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    signalementData!['quartier'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
        actions: [
          // ✅ Bouton prendre en charge (technicien seulement)
          if (_isTechnicienOuAdmin && statut == 'en attente')
            TextButton.icon(
              onPressed: _prendreEnCharge,
              icon: const Icon(Icons.handshake, color: Colors.white, size: 18),
              label: const Text(
                'Prendre en charge',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ Bandeau infos signalement (statut + priorité + catégorie + technicien)
                Container(
                  color: _statutColor(statut).withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Statut
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statutColor(statut),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statut.isEmpty ? 'N/A' : statut,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Priorité
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _prioriteColor(priorite).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _prioriteColor(
                                  priorite,
                                ).withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _prioriteIcon(priorite),
                                  size: 12,
                                  color: _prioriteColor(priorite),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  priorite,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _prioriteColor(priorite),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Catégorie
                          if (categorie.isNotEmpty)
                            Text(
                              categorie,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                      // Technicien assigné
                      if (technicien != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.engineering,
                                size: 14,
                                color: Color(0xFF6A1B9A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Technicien : $technicien',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6A1B9A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ✅ Historique des statuts
                if (historique.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historique',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        ...historique.map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${h['ancien_statut'] ?? '?'} → ${h['nouveau_statut']}  •  ${h['nom_utilisateur'] ?? ''}  •  ${_formatDate(h['date_changement']?.toString())}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Messages
                Expanded(
                  child: commentaires.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 52,
                                color: Colors.black26,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Aucun message pour l\'instant',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: commentaires.length,
                          itemBuilder: (_, i) => _buildBubble(commentaires[i]),
                        ),
                ),

                // Saisie message
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (editingId != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => setState(() {
                            editingId = null;
                            messageCtrl.clear();
                          }),
                        ),
                      Expanded(
                        child: TextField(
                          controller: messageCtrl,
                          decoration: InputDecoration(
                            hintText: editingId != null
                                ? 'Modifier le message...'
                                : 'Écrire un message...',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          onSubmitted: (_) => _envoyer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: isSending ? null : _envoyer,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6A1B9A),
                            shape: BoxShape.circle,
                          ),
                          child: isSending
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  editingId != null ? Icons.check : Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> c) {
    final isMine = _isMyComment(c);
    final texte = c['message'] ?? c['contenu'] ?? '';
    final auteur = c['nom_utilisateur'] ?? c['auteur'] ?? 'Utilisateur';
    final role = c['role'] ?? '';
    final date = _formatDate(c['date_commentaire']?.toString());
    final id = c['id_commentaire'] ?? c['id'] ?? 0;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: role == 'technicien'
                          ? Colors.orange
                          : role == 'admin'
                          ? Colors.red
                          : Colors.teal,
                      child: Text(
                        auteur.isNotEmpty ? auteur[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$auteur • $role',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? const Color(0xFF6A1B9A) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                texte,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        editingId = id;
                        messageCtrl.text = texte;
                      }),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _supprimerCommentaire(id),
                      child: const Icon(
                        Icons.delete,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
