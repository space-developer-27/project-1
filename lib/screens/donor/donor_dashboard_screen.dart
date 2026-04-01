// ── screens/donor/donor_dashboard_screen.dart ────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home_screen.dart';

class DonorDashboardScreen extends StatefulWidget {
  final String name;
  final String bloodGroup;
  final String availability;

  const DonorDashboardScreen({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.availability,
  });

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  List<dynamic> _requests = [];
  bool _loading           = true;
  String _message         = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final res = await ApiService.donorDashboard();
    setState(() {
      _loading  = false;
      if (res['success'] == true) {
        _requests = res['requests'] ?? [];
        _message  = res['message'] ?? '';
      } else {
        _message = res['message'] ?? 'Failed to load dashboard';
      }
    });
  }

  Future<void> _respond(int requestId, String action) async {
    final res = await ApiService.donorUpdateRequest(requestId, action);
    _snack(res['message'] ?? 'Done');
    _loadDashboard();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Donor Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFB11226),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.clearToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Column(children: [
        // ── Profile Banner ──────────────────────────────
        Container(
          width: double.infinity,
          color: const Color(0xFFB11226),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Text(
                widget.bloodGroup,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.availability == 'Available'
                      ? Colors.green
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(widget.availability,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ),
            ]),
          ]),
        ),

        // ── Request List ────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFB11226)))
              : _requests.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          const Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green),
                          const SizedBox(height: 12),
                          Text(
                            _message.isNotEmpty
                                ? _message
                                : 'No pending requests for your blood group',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                        ]))
                  : RefreshIndicator(
                      onRefresh: _loadDashboard,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (_, i) =>
                            _RequestCard(
                              data: _requests[i],
                              onAccept: () => _respond(
                                  _requests[i]['request_id'], 'accept'),
                              onReject: () => _respond(
                                  _requests[i]['request_id'], 'reject'),
                            ),
                      ),
                    ),
        ),
      ]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard(
      {required this.data,
      required this.onAccept,
      required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isEmergency = data['urgency'] == 'Emergency';
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: isEmergency
                ? const Color(0xFFB11226)
                : const Color(0xFF2C7BE5),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Request #${data['request_id']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEmergency ? '🚨 Emergency' : 'Normal',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ]),
        ),
        // Details
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _Row(Icons.person, 'Patient', data['patient_name']),
            _Row(Icons.bloodtype, 'Blood Group', data['blood_group']),
            _Row(Icons.water_drop, 'Units',
                data['units']?.toString() ?? ''),
            _Row(Icons.local_hospital, 'Hospital', data['hospital']),
            _Row(Icons.phone, 'Contact', data['contact']),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(0, 42)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(0, 42)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13)),
        Expanded(
            child: Text(value ?? 'N/A',
                style: const TextStyle(fontSize: 13, color: Colors.grey))),
      ]),
    );
  }
}
