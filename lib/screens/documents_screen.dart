import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentRequirement {
  final String type; // matches backend DocumentType enum
  final String title;
  final String subtitle;
  final IconData icon;

  const _DocumentRequirement(this.type, this.title, this.subtitle, this.icon);
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  static const _bg = Color(0xFF081814);
  static const _card = Color(0xFF0D2A22);
  static const _green = Color(0xFF49D86A);

  final List<_DocumentRequirement> _requirements = const [
    _DocumentRequirement(
      'ID_DOCUMENT',
      'ID Document',
      'A clear photo or scan of your SA ID or passport',
      Icons.badge_outlined,
    ),
    _DocumentRequirement(
      'PROOF_OF_ADDRESS',
      'Proof of Address',
      'A utility bill, lease, or bank statement (not older than 3 months)',
      Icons.home_outlined,
    ),
    _DocumentRequirement(
      'PROOF_OF_INCOME',
      'Proof of Income',
      'A recent payslip, or a signed letter if self-employed',
      Icons.receipt_long_outlined,
    ),
    _DocumentRequirement(
      'BANK_CONFIRMATION_LETTER',
      'Bank Confirmation Letter',
      'Confirms the account we\'ll pay claims into',
      Icons.account_balance_outlined,
    ),
  ];

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _uploadedByType = {};
  String? _uploadingType;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');

      final docs = await ApiService.getMyDocuments(token);
      final map = <String, dynamic>{};
      for (final doc in docs) {
        // Keep the most recent upload per type (list is already newest-first).
        map.putIfAbsent(doc['documentType'], () => doc);
      }
      setState(() => _uploadedByType = map);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFor(_DocumentRequirement req) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true, // needed so bytes are available on web
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read that file. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _uploadingType = req.type);

    try {
      final token = await StorageService.getToken();
      if (token == null) throw Exception('You need to be signed in to do that.');

      await ApiService.uploadDocument(
        token,
        bytes,
        picked.name,
        req.type,
      );

      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${req.title} uploaded'),
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
      if (mounted) setState(() => _uploadingType = null);
    }
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
          'My Documents',
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
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'These help us verify your account and speed up your claims. Uploading a new file for a document type replaces the old one on review.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._requirements.map(_buildDocCard),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDocCard(_DocumentRequirement req) {
    final uploaded = _uploadedByType[req.type];
    final isUploading = _uploadingType == req.type;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: uploaded != null
              ? _green.withOpacity(0.4)
              : Colors.grey[600]!.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(req.icon, color: _green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  req.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                if (uploaded != null)
                  Row(
                    children: [
                      Icon(
                        uploaded['verified'] == true
                            ? Icons.verified
                            : Icons.check_circle,
                        size: 14,
                        color: _green,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          uploaded['verified'] == true
                              ? 'Uploaded & verified'
                              : 'Uploaded - awaiting review',
                          style: GoogleFonts.inter(fontSize: 12, color: _green),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : () => _uploadFor(req),
                    icon: isUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _green),
                          )
                        : Icon(
                            uploaded != null ? Icons.refresh : Icons.upload_outlined,
                            size: 16,
                            color: _green,
                          ),
                    label: Text(
                      uploaded != null ? 'Replace file' : 'Upload',
                      style: GoogleFonts.inter(fontSize: 13, color: _green),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _green.withOpacity(0.4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
