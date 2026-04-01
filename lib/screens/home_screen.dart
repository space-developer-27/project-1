// ── screens/home_screen.dart ──────────────────────────────────
import 'package:flutter/material.dart';
import 'donor/donor_login_screen.dart';
import 'donor/donor_register_screen.dart';
import 'admin/admin_login_screen.dart';
import 'client/client_portal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Logo / Header ───────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFB11226),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bloodtype,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                'VIT Blood Bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11226),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Donate Blood. Save Lives.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ── Portal Cards ─────────────────────────────
              _PortalCard(
                icon: Icons.person_add,
                title: 'Donor Portal',
                subtitle: 'Register or login to donate blood',
                color: const Color(0xFFB11226),
                actions: [
                  _CardButton(
                    label: 'Login',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const DonorLoginScreen())),
                  ),
                  _CardButton(
                    label: 'Register',
                    outlined: true,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const DonorRegisterScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _PortalCard(
                icon: Icons.local_hospital,
                title: 'Public Portal',
                subtitle: 'Request blood or check your request status',
                color: const Color(0xFF2C7BE5),
                actions: [
                  _CardButton(
                    label: 'Enter',
                    color: const Color(0xFF2C7BE5),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ClientPortalScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _PortalCard(
                icon: Icons.admin_panel_settings,
                title: 'Admin Portal',
                subtitle: 'Manage donors, requests and activity',
                color: const Color(0xFF28A745),
                actions: [
                  _CardButton(
                    label: 'Admin Login',
                    color: const Color(0xFF28A745),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AdminLoginScreen())),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Nearby Hospitals ─────────────────────────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nearby Hospitals',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HospitalChip('OneHealth Super Speciality'),
                  _HospitalChip('Annai Arul Hospital'),
                  _HospitalChip('Kasthuri Hospital'),
                  _HospitalChip('VIT Chennai Health Centre'),
                ],
              ),
              const SizedBox(height: 30),
              const Text('© 2026 VIT Blood Bank Management System',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────

class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Widget> actions;

  const _PortalCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ]),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: actions
                .map((b) => Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: b,
                    )))
                .toList()),
          ],
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final Color? color;

  const _CardButton(
      {required this.label,
      required this.onTap,
      this.outlined = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFB11226);
    return outlined
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
                foregroundColor: c,
                side: BorderSide(color: c),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(label))
        : ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: c,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(label));
  }
}

class _HospitalChip extends StatelessWidget {
  final String name;
  const _HospitalChip(this.name);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDEE2E6)),
    );
  }
}
