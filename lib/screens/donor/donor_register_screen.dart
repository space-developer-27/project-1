// ── screens/donor/donor_register_screen.dart ─────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'donor_login_screen.dart';

class DonorRegisterScreen extends StatefulWidget {
  const DonorRegisterScreen({super.key});

  @override
  State<DonorRegisterScreen> createState() => _DonorRegisterScreenState();
}

class _DonorRegisterScreenState extends State<DonorRegisterScreen> {
  final _regnoCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();

  String _blood  = '';
  String _gender = '';
  String _avail  = 'Available';
  bool _loading  = false;
  bool _obscure  = true;

  final _bloods  = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];
  final _genders = ['Male','Female','Other'];
  final _avails  = ['Available','Not Available'];

  Future<void> _register() async {
    if ([_regnoCtrl.text, _nameCtrl.text, _emailCtrl.text,
         _phoneCtrl.text, _passCtrl.text].any((s) => s.trim().isEmpty) ||
        _blood.isEmpty || _gender.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);

    final res = await ApiService.donorRegister({
      'regno':    _regnoCtrl.text.trim(),
      'name':     _nameCtrl.text.trim(),
      'email':    _emailCtrl.text.trim(),
      'phone':    _phoneCtrl.text.trim(),
      'blood':    _blood,
      'gender':   _gender,
      'avail':    _avail,
      'password': _passCtrl.text,
    });

    setState(() => _loading = false);

    if (res['success'] == true) {
      _snack('Registered successfully! 🎉');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DonorLoginScreen()));
    } else {
      _snack(res['message'] ?? 'Registration failed');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  Widget _dropdown(
      String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        hint: Text('Select $label'),
      ),
      const SizedBox(height: 16),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C7BE5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(children: [
          const Icon(Icons.person_add, color: Color(0xFF2C7BE5), size: 56),
          const SizedBox(height: 10),
          const Text('Become a Donor',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C7BE5))),
          const SizedBox(height: 6),
          const Text(
              'Register to help save lives at VIT Chennai',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),

          // ── Fields ───────────────────────────────────
          _field(_regnoCtrl, 'Registration Number', Icons.badge),
          _field(_nameCtrl,  'Full Name',            Icons.person),
          _field(_emailCtrl, 'Email',                Icons.email,
              type: TextInputType.emailAddress),
          _field(_phoneCtrl, 'Phone Number',         Icons.phone,
              type: TextInputType.phone),

          _dropdown('Blood Group', _bloods, _blood,
              (v) => setState(() => _blood = v!)),
          _dropdown('Gender', _genders, _gender,
              (v) => setState(() => _gender = v!)),
          _dropdown('Availability', _avails, _avail,
              (v) => setState(() => _avail = v!)),

          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon:
                    Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),

          _loading
              ? const CircularProgressIndicator(color: Color(0xFF2C7BE5))
              : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C7BE5)),
                  child: const Text('Register',
                      style: TextStyle(fontSize: 16))),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const DonorLoginScreen())),
            child: const Text('Already a donor? Login here',
                style: TextStyle(color: Color(0xFF2C7BE5))),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
