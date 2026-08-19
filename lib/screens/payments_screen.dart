import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  static const _bg = Color(0xFF081814);
  static const _card = Color(0xFF0D2A22);
  static const _green = Color(0xFF49D86A);

  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _isUploadingProof = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');
      final history = await ApiService.getMyPaymentHistory(token);
      if (!mounted) return;
      setState(() => _history = history);
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
      case 'PENDING':
        return Colors.blue;
      case 'OVERDUE':
        return Colors.red;
      case 'PAID':
        return _green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    final date = DateTime.tryParse(iso);
    if (date == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final hasCover = userModel.hasCover;
    final isSuspended = userModel.policyStatus == 'LAPSED';

    // The most recent record is the current/upcoming one (list is newest-first).
    final current = _history.isNotEmpty ? _history.first : null;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _bg,
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Premiums and payment history',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _loadHistory,
                  icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasCover
                ? _buildNoCoverState()
                : RefreshIndicator(
                    onRefresh: _loadHistory,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isSuspended) _buildSuspendedBanner(),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator(color: _green)),
                            )
                          else if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(_error!, style: GoogleFonts.inter(color: Colors.white70)),
                            )
                          else ...[
                            if (current != null) _buildCurrentDueCard(current),
                            const SizedBox(height: 16),
                            _buildHowToPayCard(userModel),
                            const SizedBox(height: 24),
                            Text(
                              'Payment history',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_history.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No payment history yet.',
                                  style: GoogleFonts.inter(color: Colors.white38),
                                ),
                              )
                            else
                              ..._history.map((r) => _buildHistoryTile(r)),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF212121),
        currentIndex: 2,
        selectedItemColor: _green,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/claims');
          } else if (index == 2) {
            return;
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

  Widget _buildNoCoverState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined, color: Colors.white.withOpacity(0.2), size: 48),
            const SizedBox(height: 12),
            Text(
              "You don't have cover yet, so there's nothing to bill.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your cover is suspended due to a missed payment. Pay the outstanding amount below to reactivate it.',
              style: GoogleFonts.inter(color: Colors.red[100], fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDueCard(dynamic record) {
    final status = record['status'] as String? ?? 'PENDING';
    final isPaid = status == 'PAID';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor(status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPaid ? 'Last payment' : 'Amount due',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'R${record['totalDue'] ?? record['amountDue'] ?? '-'}',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((record['penaltyAmount'] ?? 0).toString() != '0' &&
              (record['penaltyAmount'] ?? 0).toString() != '0.00' &&
              (record['penaltyAmount'] ?? 0).toString() != '0.0')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Includes R${record['penaltyAmount']} late payment penalty',
                style: GoogleFonts.inter(color: Colors.red[200], fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            isPaid
                ? 'Paid on ${_formatDate(record['paidAt'])}'
                : 'Due ${_formatDate(record['dueDate'])}',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
          if (!isPaid) ...[
            const SizedBox(height: 16),
            _buildProofOfPaymentSection(record),
          ],
        ],
      ),
    );
  }

  Widget _buildProofOfPaymentSection(dynamic record) {
    final proofStatus = record['proofOfPaymentStatus'] as String? ?? 'NOT_SUBMITTED';

    if (proofStatus == 'PENDING_REVIEW') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_top, color: Colors.blue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Proof of payment submitted - awaiting review.',
                style: GoogleFonts.inter(color: Colors.blue[100], fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (proofStatus == 'REJECTED') ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your proof of payment wasn\'t accepted'
                    '${(record['proofOfPaymentRejectionReason'] ?? '').toString().isNotEmpty ? ': ${record['proofOfPaymentRejectionReason']}' : '.'}'
                    ' Please upload a new one.',
                    style: GoogleFonts.inter(color: Colors.red[100], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isUploadingProof ? null : () => _uploadProof(record['id']),
            icon: _isUploadingProof
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _green),
                  )
                : const Icon(Icons.upload_outlined, size: 18, color: _green),
            label: Text(
              proofStatus == 'REJECTED' ? 'Upload new proof of payment' : 'Upload proof of payment',
              style: GoogleFonts.inter(color: _green, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _green.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadProof(int paymentRecordId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true, // needed so bytes are available on web
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) return;

    setState(() => _isUploadingProof = true);

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');

      await ApiService.uploadProofOfPayment(token, paymentRecordId, bytes, picked.name);
      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proof of payment uploaded - awaiting review'),
            backgroundColor: Colors.green,
          ),
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
    } finally {
      if (mounted) setState(() => _isUploadingProof = false);
    }
  }

  Widget _buildHowToPayCard(UserModel userModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: _green, size: 20),
              const SizedBox(width: 8),
              Text(
                'How to pay',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'EFT your premium to Claimly\'s account and use your policy number as the reference. '
            'Once received, our team confirms it and your account is updated automatically.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),
          _payDetailRow('Bank', 'FNB (placeholder - update with real details)'),
          _payDetailRow('Account name', 'Claimly (Pty) Ltd'),
          _payDetailRow('Account number', '0000000000'),
          _payDetailRow('Reference', userModel.selectedProduct.isNotEmpty
              ? '${userModel.fullName} - ${userModel.selectedTier}'
              : userModel.fullName),
        ],
      ),
    );
  }

  Widget _payDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(dynamic record) {
    final status = record['status'] as String? ?? 'PENDING';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'PAID' ? Icons.check_circle : Icons.hourglass_top,
              color: _statusColor(status),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'R${record['totalDue'] ?? record['amountDue'] ?? '-'}',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  status == 'PAID'
                      ? 'Paid ${_formatDate(record['paidAt'])}'
                      : 'Due ${_formatDate(record['dueDate'])}',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}
