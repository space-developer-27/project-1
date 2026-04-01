// ── screens/client/client_portal_screen.dart ─────────────────
import 'package:flutter/material.dart';
import 'request_blood_screen.dart';
import 'request_status_screen.dart';

class ClientPortalScreen extends StatelessWidget {
  const ClientPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Public Portal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C7BE5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital,
                color: Color(0xFF2C7BE5), size: 70),
            const SizedBox(height: 16),
            const Text('What do you need?',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Request blood in an emergency or track an existing request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 50),

            _BigButton(
              icon: Icons.water_drop,
              label: 'Request Blood',
              subtitle: 'Submit a new blood request',
              color: const Color(0xFFB11226),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const RequestBloodScreen())),
            ),
            const SizedBox(height: 20),
            _BigButton(
              icon: Icons.search,
              label: 'Check Request Status',
              subtitle: 'Track an existing blood request',
              color: const Color(0xFF2C7BE5),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const RequestStatusScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BigButton(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ]),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white70, size: 18),
        ]),
      ),
    );
  }
}
