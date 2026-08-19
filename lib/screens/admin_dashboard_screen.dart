import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'admin_chat_conversation_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _users = [];
  List<dynamic> _claims = [];
  List<dynamic> _admins = [];
  List<dynamic> _pendingPolicies = [];
  List<dynamic> _conversations = [];
  List<dynamic> _outstandingPayments = [];
  String? _token;
  late TabController _tabController;

  static const _bg = Color(0xFF081814);
  static const _card = Color(0xFF0D2A22);
  static const _green = Color(0xFF49D86A);

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    final tabCount = userModel.isSuperAdmin ? 6 : 5;
    _tabController = TabController(length: tabCount, vsync: this);
    _loadEverything();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        ApiService.getPendingPolicies(token),
        ApiService.getAdminConversations(token),
        ApiService.getOutstandingPayments(token),
        if (userModel.isSuperAdmin) ApiService.getAdmins(token),
      ]);

      setState(() {
        _users = results[0];
        _claims = results[1];
        _pendingPolicies = results[2];
        _conversations = results[3];
        _outstandingPayments = results[4];
        if (userModel.isSuperAdmin) _admins = results[5];
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
    final tabs = <String>['Overview', 'Users', 'Claims', 'Payments', 'Chat', if (userModel.isSuperAdmin) 'Admins'];

    return Scaffold(
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
            controller: _tabController,
            isScrollable: tabs.length > 3,
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
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(userModel),
                      _buildUsersTab(userModel),
                      _buildClaimsTab(userModel),
                      _buildPaymentsTab(),
                      _buildChatTab(),
                      if (userModel.isSuperAdmin) _buildAdminsTab(),
                    ],
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

  // ============ OVERVIEW TAB ============

  Widget _buildOverviewTab(UserModel userModel) {
    final totalUsers = _users.length;
    final pending = _users.where((u) => u['status'] == 'PENDING_APPROVAL').length;
    final active = _users.where((u) => u['status'] == 'ACTIVE').length;
    // "Covered" means an ACTIVE policy specifically - a PENDING policy still
    // counts as hasCover=true on the backend (a policy row exists), but the
    // customer isn't actually covered yet until an admin approves it.
    final covered = _users.where((u) => u['policyStatus'] == 'ACTIVE').length;
    final suspended = _users.where((u) => u['status'] == 'SUSPENDED').length;
    final totalClaims = _claims.length;
    final awaitingReview = _claims.where((c) => c['status'] == 'SUBMITTED').length;

    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'At a glance',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _statCard('Customers', '$totalUsers', Icons.people, _green, () {
                _tabController.animateTo(1);
              }),
              _statCard('Pending', '$pending', Icons.hourglass_top, Colors.orange, () {
                _tabController.animateTo(1);
              }),
              _statCard('Covered', '$covered', Icons.shield, _green, () {
                _tabController.animateTo(1);
              }),
              _statCard('Suspended', '$suspended', Icons.block, Colors.redAccent, () {
                _tabController.animateTo(1);
              }),
              _statCard('Claims', '$totalClaims', Icons.description, Colors.blueAccent, () {
                _tabController.animateTo(2);
              }),
              _statCard('Awaiting', '$awaitingReview', Icons.pending_actions, Colors.amber, () {
                _tabController.animateTo(2);
              }),
              _statCard('Covers pending', '${_pendingPolicies.length}', Icons.shield_moon,
                  Colors.orangeAccent, () {}),
              _statCard(
                'Overdue',
                '${_outstandingPayments.where((p) => p['status'] == 'OVERDUE').length}',
                Icons.money_off,
                Colors.red,
                () => _tabController.animateTo(3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_pendingPolicies.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.shield_moon, color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Cover awaiting approval (${_pendingPolicies.length})',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._pendingPolicies.map((p) => _buildPendingPolicyCard(p)),
            const SizedBox(height: 20),
          ],
          if (pending > 0) ...[
            Text(
              'Needs your attention',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ..._users
                .where((u) => u['status'] == 'PENDING_APPROVAL')
                .take(3)
                .map((u) => _buildUserCard(u)),
            if (pending > 3)
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text('View all $pending pending →',
                    style: GoogleFonts.inter(color: _green)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingPolicyCard(dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openUserDetail(p['userId']),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          '${p['productType'] ?? ''} · ${p['tier'] ?? ''}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${p['userFullName'] ?? ''} · ${p['userEmail'] ?? ''}',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    p['monthlyPremium'] != null ? 'R${p['monthlyPremium']}/mo' : '',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _actionButton('Approve cover', Icons.check_circle_outline, _green,
                      () => _approveCover(p['id'])),
                  const Spacer(),
                  Text(
                    'Tap for full details',
                    style: GoogleFonts.inter(color: Colors.white30, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approveCover(int policyId) =>
      _runAction(() => ApiService.approveCover(_token!, policyId));

  Widget _statCard(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _card.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    final covered = _users.where((u) => u['policyStatus'] == 'ACTIVE').toList();
    final others = _users
        .where((u) => u['status'] != 'PENDING_APPROVAL' && u['policyStatus'] != 'ACTIVE')
        .toList();

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
          if (covered.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.shield, color: _green, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Covered customers (${covered.length})',
                  style: GoogleFonts.spaceGrotesk(
                    color: _green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...covered.map((u) => _buildUserCard(u)),
            const SizedBox(height: 20),
          ],
          Text(
            'Other customers (${others.length})',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (others.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Nobody else here.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
            ),
          ...others.map((u) => _buildUserCard(u)),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic u) {
    final status = u['status'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: u['policyStatus'] == 'ACTIVE'
              ? _green.withOpacity(0.35)
              : u['policyStatus'] == 'PENDING'
                  ? Colors.orangeAccent.withOpacity(0.35)
                  : Colors.grey[700]!.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openUserDetail(u['id']),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                    u['policyStatus'] == 'ACTIVE'
                        ? '${u['productType'] ?? ''} · ${u['tier'] ?? ''}'
                        : u['policyStatus'] == 'PENDING'
                            ? '${u['productType'] ?? ''} · ${u['tier'] ?? ''} (pending)'
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
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ USER DETAIL (with documents) ============

  Future<void> _openUserDetail(int userId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<Map<String, dynamic>>(
          future: ApiService.getAdminUserDetail(_token!, userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _green));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              );
            }
            final detail = snapshot.data!;
            return _buildUserDetailSheet(detail, scrollController);
          },
        ),
      ),
    );
  }

  Widget _buildUserDetailSheet(Map<String, dynamic> d, ScrollController scrollController) {
    final documents = (d['documents'] as List?) ?? [];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                d['fullName'] ?? '',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            _buildStatusBadge(d['status'] ?? ''),
          ],
        ),
        const SizedBox(height: 16),
        _detailSection('Contact', [
          _detailRow('Email', d['email']),
          _detailRow('Phone', d['phoneNumber']),
          _detailRow('SA ID', d['idNumber']),
        ]),
        _detailSection('Personal', [
          _detailRow('Date of birth', d['dateOfBirth']),
          _detailRow('Gender', d['gender']),
          _detailRow('Employment status', d['employmentStatus']),
          _detailRow('Occupation', d['occupation']),
          _detailRow('Monthly income', d['monthlyIncome'] != null ? 'R${d['monthlyIncome']}' : null),
          _detailRow('Next of kin', d['nextOfKinName']),
          _detailRow('Next of kin phone', d['nextOfKinPhone']),
        ]),
        _detailSection('Cover', [
          _detailRow('Has cover', d['hasCover'] == true ? 'Yes' : 'No'),
          if (d['hasCover'] == true) ...[
            _detailRow('Product', d['productType']),
            _detailRow('Tier', d['tier']),
            _detailRow('Policy number', d['policyNumber']),
            _detailRow('Payment method', d['paymentMethod']),
            _detailRow('Monthly premium', d['monthlyPremium'] != null ? 'R${d['monthlyPremium']}' : null),
          ],
        ]),
        const SizedBox(height: 8),
        Text(
          'Documents (${documents.length})',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No documents uploaded yet.',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
            ),
          )
        else
          ...documents.map((doc) => _buildDocumentTile(doc)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _detailSection(String title, List<Widget?> rows) {
    final visible = rows.whereType<Widget>().toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...visible,
          ],
        ),
      ),
    );
  }

  Widget? _detailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(dynamic doc) {
    final type = (doc['documentType'] ?? '').toString().replaceAll('_', ' ');
    final verified = doc['verified'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.verified : Icons.insert_drive_file_outlined,
            color: verified ? _green : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  doc['fileName'] ?? '',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openDocument(doc['fileUrl']),
            child: Text('View', style: GoogleFonts.inter(color: _green, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String? fileUrl) async {
    if (fileUrl == null) return;
    final url = Uri.parse('${ApiService.mediaBaseUrl}$fileUrl');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that file'), backgroundColor: Colors.red),
      );
    }
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
                if (userModel.isSuperAdmin && status == 'APPROVED') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionButton('Mark as Paid', Icons.payments, _green,
                          () => _markAsPaid(c['id'])),
                    ],
                  ),
                ],
                if (status == 'PAID') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: _green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Paid R${c['payoutAmount'] ?? '-'} · ref ${c['payoutReference'] ?? '-'}',
                            style: GoogleFonts.inter(color: _green, fontSize: 12),
                          ),
                        ),
                      ],
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

  Future<void> _markAsPaid(int claimId) async {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text('Mark claim as Paid', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Payout amount',
                labelStyle: TextStyle(color: Colors.white54),
                prefixText: 'R ',
                prefixStyle: TextStyle(color: Colors.white70),
                hintText: 'e.g. 5000',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: referenceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Payout reference',
                labelStyle: TextStyle(color: Colors.white54),
                hintText: 'e.g. bank transaction ref',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('Mark as Paid', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Defensive cleanup - strip anything but digits and a decimal point,
      // in case someone types "R5000" or "5,000" despite the prefix.
      final amount = amountController.text
          .trim()
          .replaceAll(RegExp(r'[^0-9.]'), '');
      final reference = referenceController.text.trim();
      if (amount.isEmpty || double.tryParse(amount) == null || reference.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid amount and a reference'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      await _runAction(() => ApiService.markClaimAsPaid(
            _token!,
            claimId,
            payoutAmount: amount,
            payoutReference: reference,
          ));
    }
  }

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

  // ============ PAYMENTS TAB ============

  Widget _buildPaymentsTab() {
    if (_outstandingPayments.isEmpty) {
      return _buildEmptyState('No outstanding payments right now', Icons.payments_outlined);
    }

    final overdue = _outstandingPayments.where((p) => p['status'] == 'OVERDUE').toList();
    final pending = _outstandingPayments.where((p) => p['status'] != 'OVERDUE').toList();

    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (overdue.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Overdue - cover suspended (${overdue.length})',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...overdue.map((p) => _buildPaymentCard(p)),
            const SizedBox(height: 20),
          ],
          if (pending.isNotEmpty) ...[
            Text(
              'Due soon (${pending.length})',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pending.map((p) => _buildPaymentCard(p)),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(dynamic p) {
    final status = p['status'] as String? ?? 'PENDING';
    final isOverdue = status == 'OVERDUE';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.grey[700]!.withOpacity(0.3),
        ),
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
                      p['userFullName'] ?? '',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${p['userEmail'] ?? ''} · ${p['productType'] ?? ''} ${p['tier'] ?? ''}',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                'R${p['totalDue'] ?? '-'}',
                style: GoogleFonts.spaceGrotesk(
                  color: isOverdue ? Colors.red : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (isOverdue && (p['penaltyAmount'] ?? 0).toString() != '0')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Includes R${p['penaltyAmount']} late payment penalty',
                style: GoogleFonts.inter(color: Colors.red[200], fontSize: 11),
              ),
            ),
          if (p['proofOfPaymentStatus'] == 'PENDING_REVIEW') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Proof of payment submitted',
                      style: GoogleFonts.inter(color: Colors.blue[100], fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openPaymentProof(p['proofOfPaymentUrl']),
                    child: Text('View', style: GoogleFonts.inter(color: _green, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _actionButton('Approve', Icons.check, _green,
                    () => _approveProof(p['id'])),
                const SizedBox(width: 8),
                _actionButton('Reject', Icons.close, Colors.redAccent,
                    () => _rejectProof(p['id'])),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _actionButton('Record Payment', Icons.check_circle_outline, _green,
                    () => _recordPayment(p['id'])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _recordPayment(int paymentRecordId) async {
    String selectedMethod = 'EFT';
    final methods = ['EFT', 'Cash', 'Card', 'Other'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _card,
          title: Text('Record payment', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How did the customer pay?',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: methods.map((m) {
                  final selected = m == selectedMethod;
                  return ChoiceChip(
                    label: Text(m),
                    selected: selected,
                    onSelected: (_) => setDialogState(() => selectedMethod = m),
                    selectedColor: _green,
                    backgroundColor: _bg,
                    labelStyle: TextStyle(color: selected ? Colors.black : Colors.white70),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: _green),
              child: const Text('Confirm payment', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _runAction(() => ApiService.recordPayment(
            _token!,
            paymentRecordId,
            paymentMethod: selectedMethod,
          ));
    }
  }

  Future<void> _openPaymentProof(String? fileUrl) async {
    if (fileUrl == null) return;
    final url = Uri.parse('${ApiService.mediaBaseUrl}$fileUrl');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that file'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approveProof(int paymentRecordId) =>
      _runAction(() => ApiService.approveProofOfPayment(_token!, paymentRecordId));

  Future<void> _rejectProof(int paymentRecordId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text('Reject proof of payment', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Why is this being rejected? (shown to the customer)',
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
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runAction(() => ApiService.rejectProofOfPayment(
            _token!,
            paymentRecordId,
            reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
          ));
    }
  }

  // ============ CHAT TAB ============

  Widget _buildChatTab() {
    if (_conversations.isEmpty) {
      return _buildEmptyState('No support conversations yet', Icons.chat_bubble_outline);
    }
    return RefreshIndicator(
      onRefresh: _loadEverything,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final c = _conversations[index];
          final unread = (c['unreadCount'] ?? 0) as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: unread > 0
                    ? _green.withOpacity(0.4)
                    : Colors.grey[700]!.withOpacity(0.3),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminChatConversationScreen(
                      customerId: c['customerId'],
                      customerName: c['customerName'] ?? 'Customer',
                    ),
                  ),
                );
                _loadEverything();
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['customerName'] ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$unread new',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                if (!isSuperAdminAccount) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionButton('Demote to Customer', Icons.arrow_downward, Colors.amber,
                          () => _demoteToCustomer(a['id'], a['fullName'] ?? 'this admin')),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _demoteToCustomer(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text('Demote to Customer', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
        content: Text(
          'Remove Admin access from $name and change them back to a regular Customer account? They\'ll be emailed about this change.',
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
            child: const Text('Demote', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runAction(() => ApiService.demoteToCustomer(_token!, id));
    }
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
