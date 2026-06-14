import 'package:flutter/material.dart';
import 'package:frontend/infrastructure/date_formatter.dart';

/// Carte utilisateur
class UserCard extends StatelessWidget {
  final String nom;
  final String email;
  final String? specialite;
  final String role;

  const UserCard({
    super.key,
    required this.nom,
    required this.email,
    required this.role,
    this.specialite,
  });

  Color _roleColor() {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.green.shade50;
      case 'technicien':
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _roleColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          role == 'admin'
              ? Icons.star
              : role == 'technicien'
              ? Icons.build
              : Icons.person,
          color: Colors.blue.shade700,
        ),
        title: Text(nom),
        subtitle: Text(email),
        trailing: specialite != null && specialite!.isNotEmpty
            ? Text(specialite!)
            : null,
      ),
    );
  }
}

/// Bulle de message pour le chat
class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String date;
  final bool isMine;
  final bool isTechnicien;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.date,
    required this.isMine,
    required this.isTechnicien,
  });

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    if (isMine) {
      bubbleColor = const Color(0xFFDCF8C6).withOpacity(0.85);
    } else if (isTechnicien) {
      bubbleColor = const Color(0xFFE1F5FE).withOpacity(0.85);
    } else {
      bubbleColor = Colors.grey.shade200.withOpacity(0.9);
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              DateFormatter.format(date),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton personnalisé
class CustomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF0D47A1),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
