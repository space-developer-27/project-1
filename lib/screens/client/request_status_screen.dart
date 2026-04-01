// ── screens/client/request_status_screen.dart ────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RequestStatusScreen extends StatefulWidget {
  final String? prefillReqId;
  const RequestStatusScreen({super.key, this.prefillReqId});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  late final TextEditingController _regnoCtrl;
  late final TextEditingController _reqidCtrl;
  Map<String, dynamic>? _result;
  bool _loading      = false;
  bool _searched     = false;

  @override
  void initState() {
    super.initState();
    _regnoCtrl = TextEditingController();
    _reqidCtrl = TextEditingController(text: widget.prefillReqId ?? '');
    if (widget.prefillReqId != null && widget.prefillReqId!.isNotEmpty) {
      _check();
    }
  }

  Future<void> _check() async {
    final regno = _regnoCtrl.text.trim();
    final reqid = _reqidCtrl.text.trim();
    if (regno.isEmpty && reqid.isEmpty) {
      _snack('Enter a Request ID or Registration Number');
      return;
    }
    setState(() { _loading = true; _searched = true; });

    final res = await ApiService.checkStatus(
        regno: regno.isEmpty ? null : regno,
        reqid: reqid.isEmpty ? null : reqid);

    setState(() {
      _loading = false;
      _result  = res['success'] == true ? res['request'] : null;
    });
    if (res['success'] != true) _snack(res['message'] ?? 'Not found');
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  Color _statusColor(String? s) {
    switch (s) {
      case 'Satisfied':   return Colors.green;
      case 'Unsatisfied': return Colors.red;
      default:            return Colors.orange;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'Satisfied':   return Icons.check_circle;
      case 'Unsatisfied': return Icons.cancel;
      default:            return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Request Status'),
        backgroundColor: const Color(0xFF2C7BE5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.search, color: Color(0xFF2C7BE5), size: 52),
          const SizedBox(height: 10),
          const Text(
              'Enter your Request ID or Registration Number to track your blood request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          TextField(
            controller: _reqidCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Request ID',
              prefixIcon: const Icon(Icons.confirmation_number),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('— OR —',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _regnoCtrl,
            decoration: InputDecoration(
              labelText: 'Your Registration Number',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          _loading
              ? const CircularProgressIndicator(
                  color: Color(0xFF2C7BE5))
              : ElevatedButton.icon(
                  onPressed: _check,
                  icon: const Icon(Icons.search),
                  label: const Text('Track Request',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C7BE5)),
                ),

          // ── Result Card ──────────────────────────────
          if (_searched && !_loading) ...[
            const SizedBox(height: 30),
            if (_result == null)
              const Text('No request found.',
                  style: TextStyle(color: Colors.grey, fontSize: 15))
            else
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  // Status header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _statusColor(_result!['status']),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                    ),
                    child: Column(children: [
                      Icon(_statusIcon(_result!['status']),
                          color: Colors.white, size: 44),
                      const SizedBox(height: 8),
                      Text(_result!['status'] ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  // Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _row('Request ID',
                          '#${_result!['request_id']}'),
                      _row('Patient Name',  _result!['patient_name']),
                      _row('Blood Group',   _result!['blood_group']),
                      _row('Units',         _result!['units']?.toString()),
                      _row('Urgency',       _result!['urgency']),
                      _row('Hospital',      _result!['hospital']),
                      _row('Contact',       _result!['contact']),
                      if (_result!['assigned_donor'] != null)
                        _row('Donor',       _result!['assigned_donor']),
                    ]),
                  ),
                ]),
              ),
          ],
        ]),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14)),
            Text(value ?? 'N/A',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
    );
  }
}
