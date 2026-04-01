// ── screens/admin/admin_login_screen.dart ────────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading   = false;
  bool _obscure   = true;

  Future<void> _login() async {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);

    final res =
        await ApiService.adminLogin(_userCtrl.text.trim(), _passCtrl.text);

    setState(() => _loading = false);

    if (res['success'] == true) {
      await ApiService.saveToken(res['token']);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                AdminDashboardScreen(username: res['username'] ?? 'Admin')),
      );
    } else {
      _snack(res['message'] ?? 'Login failed');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF28A745)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const Icon(Icons.admin_panel_settings,
                color: Color(0xFF28A745), size: 60),
            const SizedBox(height: 12),
            const Text('Admin Login',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28A745))),
            const SizedBox(height: 6),
            const Text('VIT Blood Bank Administration',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person)),
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
                        setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator(
                    color: Color(0xFF28A745))
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745)),
                    child: const Text('Login',
                        style: TextStyle(fontSize: 16))),
          ]),
        ),
      ),
    );
  }
}
