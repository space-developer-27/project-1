// ── screens/donor/donor_login_screen.dart ────────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'donor_dashboard_screen.dart';
import 'donor_register_screen.dart';

class DonorLoginScreen extends StatefulWidget {
  const DonorLoginScreen({super.key});

  @override
  State<DonorLoginScreen> createState() => _DonorLoginScreenState();
}

class _DonorLoginScreenState extends State<DonorLoginScreen> {
  final _regnoCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;
  bool _obscure     = true;

  Future<void> _login() async {
    if (_regnoCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);

    final res = await ApiService.donorLogin(
        _regnoCtrl.text.trim(), _passCtrl.text);

    setState(() => _loading = false);

    if (res['success'] == true) {
      await ApiService.saveToken(res['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'donor');
      await prefs.setString('name', res['name'] ?? '');
      await prefs.setString('blood_group', res['blood_group'] ?? '');
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => DonorDashboardScreen(
            name: res['name'] ?? '',
            bloodGroup: res['blood_group'] ?? '',
            availability: res['availability'] ?? '',
          )));
    } else {
      _snack(res['message'] ?? 'Login failed');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFB11226)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const Icon(Icons.bloodtype, color: Color(0xFFB11226), size: 60),
            const SizedBox(height: 12),
            const Text('Donor Login',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB11226))),
            const SizedBox(height: 6),
            const Text('Access your donor dashboard',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // ── Form ─────────────────────────────────────
            TextField(
              controller: _regnoCtrl,
              decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.badge)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator(
                    color: Color(0xFFB11226))
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login',
                        style: TextStyle(fontSize: 16))),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(
                      builder: (_) => const DonorRegisterScreen())),
              child: const Text("Don't have an account? Register here",
                  style: TextStyle(color: Color(0xFFB11226))),
            ),
          ]),
        ),
      ),
    );
  }
}
