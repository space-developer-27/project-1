// ── screens/client/request_blood_screen.dart ─────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'request_status_screen.dart';

class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _regnoCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _unitsCtrl    = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _contactCtrl  = TextEditingController();

  String _blood   = '';
  String _urgency = '';
  bool _loading   = false;

  final _bloods   = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];
  final _urgencies = ['Normal','Emergency'];

  Future<void> _submit() async {
    if ([_nameCtrl.text, _unitsCtrl.text, _hospitalCtrl.text,
         _contactCtrl.text].any((s) => s.trim().isEmpty) ||
        _blood.isEmpty || _urgency.isEmpty) {
      _snack('Please fill all required fields');
      return;
    }
    setState(() => _loading = true);

    final res = await ApiService.submitBloodRequest({
      'regno':    _regnoCtrl.text.trim(),
      'name':     _nameCtrl.text.trim(),
      'blood':    _blood,
      'units':    _unitsCtrl.text.trim(),
      'urgency':  _urgency,
      'hospital': _hospitalCtrl.text.trim(),
      'contact':  _contactCtrl.text.trim(),
    });

    setState(() => _loading = false);

    if (res['success'] == true) {
      final reqId = res['request_id']?.toString() ?? '';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request #$reqId submitted!')));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => RequestStatusScreen(prefillReqId: reqId)));
    } else {
      _snack(res['message'] ?? 'Submission failed');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  Widget _dropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChange, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChange,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        hint: Text('Select $label'),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? type, bool req = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label + (req ? ' *' : ''),
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Blood Request Form'),
        backgroundColor: const Color(0xFFB11226),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.water_drop,
              color: Color(0xFFB11226), size: 52),
          const SizedBox(height: 10),
          const Text(
              'Fill in the details. Matching donors will be\nnotified via email automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          _field(_regnoCtrl, 'Your Reg No (Optional)', Icons.badge,
              req: false),
          _field(_nameCtrl,     'Patient Name',   Icons.person),
          _dropdown('Blood Group Required', _bloods, _blood,
              (v) => setState(() => _blood = v!)),
          _field(_unitsCtrl, 'Number of Units', Icons.numbers,
              type: TextInputType.number),
          _dropdown('Urgency Level', _urgencies, _urgency,
              (v) => setState(() => _urgency = v!)),
          _field(_hospitalCtrl, 'Hospital / Location',
              Icons.local_hospital),
          _field(_contactCtrl, 'Contact Number', Icons.phone,
              type: TextInputType.phone),

          const SizedBox(height: 8),
          _loading
              ? const CircularProgressIndicator(
                  color: Color(0xFFB11226))
              : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Request',
                      style: TextStyle(fontSize: 16)),
                ),
        ]),
      ),
    );
  }
}
