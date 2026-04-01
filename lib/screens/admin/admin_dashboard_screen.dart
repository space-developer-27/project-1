// ── screens/admin/admin_dashboard_screen.dart ────────────────
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  const AdminDashboardScreen({super.key, required this.username});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  Map<String, dynamic> _stats = {};
  List<dynamic> _donors       = [];
  List<dynamic> _requests     = [];
  bool _loadingStats     = true;
  bool _loadingDonors    = true;
  bool _loadingRequests  = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    _loadStats();
    _loadDonors();
    _loadRequests();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    final res = await ApiService.adminStats();
    setState(() {
      _loadingStats = false;
      if (res['success'] == true) _stats = res;
    });
  }

  Future<void> _loadDonors() async {
    setState(() => _loadingDonors = true);
    final res = await ApiService.adminDonors();
    setState(() {
      _loadingDonors = false;
      if (res['success'] == true) _donors = res['donors'] ?? [];
    });
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    final res = await ApiService.adminRequests();
    setState(() {
      _loadingRequests = false;
      if (res['success'] == true) _requests = res['requests'] ?? [];
    });
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'Satisfied':   return Colors.green;
      case 'Unsatisfied': return Colors.red;
      default:            return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Admin — ${widget.username}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF28A745),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadAll),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.clearToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people),    text: 'Donors'),
            Tab(icon: Icon(Icons.list_alt),  text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildOverview(),
          _buildDonors(),
          _buildRequests(),
        ],
      ),
    );
  }

  // ── Overview tab ─────────────────────────────────────────
  Widget _buildOverview() {
    if (_loadingStats) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF28A745)));
    }
    final items = [
      ('Total Donors',   _stats['total_donors'],   Icons.people,    Colors.blue),
      ('Total Requests', _stats['total_requests'], Icons.list_alt,  Colors.purple),
      ('Pending',        _stats['pending'],         Icons.hourglass_empty, Colors.orange),
      ('Satisfied',      _stats['satisfied'],       Icons.check_circle,   Colors.green),
      ('Unsatisfied',    _stats['unsatisfied'],     Icons.cancel,          Colors.red),
    ];
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.4,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final (label, value, icon, color) = items[i];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 28),
                      const Spacer(),
                      Text('$value',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  // ── Donors tab ────────────────────────────────────────────
  Widget _buildDonors() {
    if (_loadingDonors) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF28A745)));
    }
    return RefreshIndicator(
      onRefresh: _loadDonors,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _donors.length,
        itemBuilder: (_, i) {
          final d = _donors[i];
          final isAvail = d['availability'] == 'Available';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFB11226),
                child: Text(d['blood_group'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              title: Text(d['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${d['reg_no']} · ${d['phone']}\n${d['email']}'),
              isThreeLine: true,
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvail ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvail ? 'Available' : 'Unavailable',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Requests tab ──────────────────────────────────────────
  Widget _buildRequests() {
    if (_loadingRequests) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF28A745)));
    }
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _requests.length,
        itemBuilder: (_, i) {
          final r = _requests[i];
          final status = r['status'] ?? 'Pending';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Request #${r['request_id']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12)),
                          ),
                        ]),
                    const SizedBox(height: 8),
                    Text(
                        '${r['patient_name']} · ${r['blood_group']} · ${r['units']} unit(s)',
                        style: const TextStyle(color: Colors.grey)),
                    Text('${r['hospital']} · ${r['urgency']}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
