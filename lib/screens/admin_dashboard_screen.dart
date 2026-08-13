import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _users = [];
  List<dynamic> _claims = [];
  List<dynamic> _admins = [];
  String? _token;

  static const _bg = Color(0xFF081814);
  static const _card = Color(0xFF0D2A22);
  static const _green = Color(0xFF49D86A);

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');
      _token = token;

      final userModel = Provider.of<UserModel>(context, listen: false);

      final results = await Future.wait([
        ApiService.getAdminUsers(token),
        ApiService.getAdminClaims(token),
        if (userModel.isSuperAdmin) ApiService.getAdmins(token),
      ]);

      setState(() {
        _users = results[0];
        _claims = results[1];
        if (userModel.isSuperAdmin) _admins = results[2];
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final tabs = <String>['Users', 'Claims', if (userModel.isSuperAdmin) 'Admins'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(
                userModel.isSuperAdmin ? Icons.admin_panel_settings : Icons.shield_outlined,
                color: _green,
              ),
              const SizedBox(width: 10),
              Text(
                userModel.isSuperAdmin ? 'Super Admin' : 'Admin',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadEverything,
              icon: const Icon(Icons.refresh, color: Colors.white70),
            ),
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.6), size: 18),
              label: Text(
                'Logout',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: _green,
            labelColor: _green,
            unselectedLabelColor: Colors.white54,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : _error != null
                ? _buildError()
                : TabBarView(
                    children: [
                      _buildUsersTab(userModel),
                      _buildClaimsTab(userModel),
                      if (userModel.isSuperAdmin) _buildAdminsTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEverything,
              style: ElevatedButton.styleFrom(backgroundColor: _green),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // ============ USERS TAB ============

  Widget _buildUsersTab(UserModel userModel) {
    if (_users.isEmpty) {
      return _buildEmptyState('No customers yet', Icons.people_outline);
    }
    final pending = _users.where((u) => u['status'] == 'PENDING_APPROVAL').toList();
    final others = _users.where((u) => u['status'] != 'PENDING_APPROVAL').toList();

    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            Text(
              'Pending approval (${pending.length})',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pending.map((u) => _buildUserCard(u)),
            const SizedBox(height: 20),
          ],
          Text(
            'All customers',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...others.map((u) => _buildUserCard(u)),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic u) {
    final status = u['status'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u['fullName'] ?? '',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      u['email'] ?? '',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildMiniStat(Icons.phone, u['phoneNumber'] ?? '-'),
              _buildMiniStat(
                Icons.shield,
                u['hasCover'] == true
                    ? '${u['productType'] ?? ''} · ${u['tier'] ?? ''}'
                    : 'No cover yet',
              ),
              _buildMiniStat(Icons.folder, '${u['documentCount'] ?? 0} documents'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (status == 'PENDING_APPROVAL')
                _actionButton('Activate', Icons.check_circle_outline, _green,
                    () => _activate(u['id'])),
              if (status == 'ACTIVE')
                _actionButton('Suspend', Icons.block, Colors.redAccent,
                    () => _suspend(u['id'])),
              if (status == 'SUSPENDED')
                _actionButton('Reactivate', Icons.restart_alt, _green,
                    () => _reactivate(u['id'])),
              if (Provider.of<UserModel>(context, listen: false).isSuperAdmin &&
                  status == 'ACTIVE') ...[
                const SizedBox(width: 8),
                _actionButton('Promote to Admin', Icons.upgrade, Colors.amber,
                    () => _promote(u['id'], u['fullName'] ?? 'this user')),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'ACTIVE':
        color = _green;
        break;
      case 'SUSPENDED':
        color = Colors.redAccent;
        break;
      case 'PENDING_APPROVAL':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white38),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: GoogleFonts.inter(color: color, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Future<void> _activate(int id) => _runAction(() => ApiService.activateUser(_token!, id));
  Future<void> _suspend(int id) => _runAction(() => ApiService.suspendUser(_token!, id));
  Future<void> _reactivate(int id) => _runAction(() => ApiService.reactivateUser(_token!, id));

  Future<void> _promote(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text('Promote to Admin', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: Text(
          'Give $name full Admin access? They\'ll be able to view and manage all customer accounts.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Promote', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runAction(() => ApiService.promoteToAdmin(_token!, id));
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await _loadEverything();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============ CLAIMS TAB ============

  Widget _buildClaimsTab(UserModel userModel) {
    if (_claims.isEmpty) {
      return _buildEmptyState('No claims submitted yet', Icons.description_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _claims.length,
        itemBuilder: (context, index) {
          final c = _claims[index];
          final status = c['status'] as String? ?? '';
          final canVerify = userModel.isSuperAdmin && status == 'SUBMITTED';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${c['claimType'] ?? ''} · ${c['claimReference'] ?? ''}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${c['userFullName'] ?? ''} · ${c['userEmail'] ?? ''}',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
                if ((c['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    c['description'],
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                ],
                if (canVerify) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionButton('Approve', Icons.check, _green,
                          () => _verifyClaim(c['id'], true)),
                      const SizedBox(width: 8),
                      _actionButton('Decline', Icons.close, Colors.redAccent,
                          () => _declineClaim(c['id'])),
                    ],
                  ),
                ] else if (!userModel.isSuperAdmin && status == 'SUBMITTED') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Only a super admin can verify this claim.',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _verifyClaim(int id, bool approve) =>
      _runAction(() => ApiService.verifyClaim(_token!, id, approve: approve));

  Future<void> _declineClaim(int id) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text('Decline claim', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Reason for declining',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runAction(() => ApiService.verifyClaim(
            _token!,
            id,
            approve: false,
            declineReason: reasonController.text.trim().isEmpty
                ? null
                : reasonController.text.trim(),
          ));
    }
  }

  // ============ ADMINS TAB (SUPER_ADMIN only) ============

  Widget _buildAdminsTab() {
    if (_admins.isEmpty) {
      return _buildEmptyState('No admin accounts yet', Icons.admin_panel_settings_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _admins.length,
        itemBuilder: (context, index) {
          final a = _admins[index];
          final status = a['status'] as String? ?? '';
          final isSuperAdminAccount = a['role'] == 'SUPER_ADMIN';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            a['fullName'] ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              a['role'],
                              style: GoogleFonts.inter(fontSize: 10, color: _green),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        a['email'] ?? '',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
                if (!isSuperAdminAccount) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _runAction(() => status == 'SUSPENDED'
                        ? ApiService.reactivateAdmin(_token!, a['id'])
                        : ApiService.suspendAdmin(_token!, a['id'])),
                    icon: Icon(
                      status == 'SUSPENDED' ? Icons.restart_alt : Icons.block,
                      color: status == 'SUSPENDED' ? _green : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.inter(color: Colors.white38)),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    await StorageService.deleteToken();
    if (!mounted) return;
    Provider.of<UserModel>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/landing');
  }
}
