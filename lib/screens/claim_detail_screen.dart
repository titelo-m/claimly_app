import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ClaimDetailScreen extends StatefulWidget {
  const ClaimDetailScreen({super.key});

  @override
  State<ClaimDetailScreen> createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> {
  static const _bg = Color(0xFF081814);
  static const _card = Color(0xFF0D2A22);
  static const _green = Color(0xFF49D86A);

  Map<String, dynamic>? _claim;
  bool _isLoading = true;
  String? _error;
  String? _claimReference;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_claimReference == null) {
      _claimReference = ModalRoute.of(context)!.settings.arguments as String;
      _loadClaim();
    }
  }

  Future<void> _loadClaim() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');
      final claim = await ApiService.getClaimDetail(token, _claimReference!);
      if (!mounted) return;
      setState(() => _claim = claim);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SUBMITTED':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      case 'APPROVED':
        return Colors.green;
      case 'PAID':
        return _green;
      case 'DECLINED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _claimReference ?? 'Claim',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  ),
                )
              : _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF212121),
        currentIndex: 1,
        selectedItemColor: _green,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/claims');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/payments');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Claims'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final claim = _claim!;
    final status = claim['status'] as String? ?? 'SUBMITTED';
    final documents = (claim['documents'] as List?) ?? [];
    final history = (claim['history'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _loadClaim,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    claim['claimType'] ?? 'Claim',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(status).withOpacity(0.3)),
                  ),
                  child: Text(
                    status.replaceAll('_', ' '),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status stepper, driven by real timestamps
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: _buildSteps(claim, status),
              ),
            ),
            const SizedBox(height: 24),

            if (status == 'DECLINED' && (claim['declineReason'] ?? '').toString().isNotEmpty) ...[
              _sectionCard(
                icon: Icons.info_outline,
                iconColor: Colors.red,
                title: 'Why this was declined',
                child: Text(
                  claim['declineReason'],
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (status == 'PAID') ...[
              _sectionCard(
                icon: Icons.payments,
                iconColor: _green,
                title: 'Payout details',
                borderColor: _green.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R${claim['payoutAmount'] ?? '-'}',
                      style: GoogleFonts.spaceGrotesk(
                        color: _green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reference: ${claim['payoutReference'] ?? '-'}',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                    ),
                    if (claim['paidAt'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Paid on ${_formatDateTime(claim['paidAt'])}',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              'What you told us',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (claim['description'] ?? '').toString().isNotEmpty
                    ? claim['description']
                    : 'No description provided.',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            if (documents.isNotEmpty) ...[
              Text(
                'Documents',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...documents.map((doc) => _buildDocumentTile(doc)),
              const SizedBox(height: 24),
            ],

            if (history.isNotEmpty) ...[
              Text(
                'History',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...history.map((h) => _buildHistoryTile(h)),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://wa.me/27600000000?text=${Uri.encodeComponent("Hi Claimly, I have a query about claim ${claim['claimReference']}")}',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                label: Text(
                  'Query this claim on WhatsApp',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps(Map<String, dynamic> claim, String status) {
    final stepOrder = ['SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'PAID'];
    final labels = ['Submitted', 'Under Review', 'Approved', 'Paid'];
    final times = [claim['submittedAt'], claim['reviewedAt'], claim['approvedAt'], claim['paidAt']];
    final isDeclined = status == 'DECLINED';
    final currentIndex = isDeclined ? 1 : stepOrder.indexOf(status);

    return List.generate(labels.length, (index) {
      final isCompleted = !isDeclined && index <= currentIndex && times[index] != null;
      final isLast = index == labels.length - 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? _green : Colors.grey[800],
                  border: Border.all(
                    color: isCompleted ? _green : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.black, size: 18)
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? _green : Colors.grey[800],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[index],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.white : Colors.white38,
                    ),
                  ),
                  if (times[index] != null)
                    Text(
                      _formatDateTime(times[index]),
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.grey[700]!.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDocumentTile(dynamic doc) {
    final filePath = (doc['filePath'] ?? '').toString().replaceAll('\\', '/');
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            doc['verified'] == true ? Icons.verified : Icons.insert_drive_file,
            color: _green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              doc['fileName'] ?? '',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18, color: Colors.white54),
            onPressed: filePath.isEmpty
                ? null
                : () async {
                    final url = Uri.parse('${ApiService.mediaBaseUrl}/$filePath');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(dynamic h) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: _green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h['comment'] ?? '${h['fromStatus'] ?? ''} → ${h['toStatus'] ?? ''}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
                if (h['changedBy'] != null)
                  Text(
                    'by ${h['changedBy']}',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                  ),
                Text(
                  _formatDateTime(h['changedAt']),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
