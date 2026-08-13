import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationMethodScreen extends StatefulWidget {
  const VerificationMethodScreen({super.key});

  @override
  State<VerificationMethodScreen> createState() =>
      _VerificationMethodScreenState();
}

class _VerificationMethodScreenState extends State<VerificationMethodScreen> {
  String? _phoneNumber;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get arguments without type casting
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _phoneNumber = args['phoneNumber']?.toString();
      _email = args['email']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081814),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Title
            Text(
              'Verify your account',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to receive your verification code',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // SMS Option (Disabled - Under Construction)
            _buildVerificationOption(
              icon: Icons.sms,
              title: 'SMS',
              subtitle: 'Receive code via SMS to $_phoneNumber',
              isEnabled: false,
              onTap: () {
                _showUnderConstructionDialog('SMS verification');
              },
            ),
            const SizedBox(height: 16),

            // Email Option (Enabled)
            _buildVerificationOption(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'Receive code via Email to $_email',
              isEnabled: true,
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/otp_verification',
                  arguments: {
                    'phoneNumber': _phoneNumber ?? '',
                    'email': _email ?? '',
                    'method': 'email',
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SMS verification is currently under construction. Please use Email verification for now.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.orange,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFF0D2A22).withOpacity(0.6)
              : Colors.grey[800]!.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? Colors.grey[600]!.withOpacity(0.35)
                : Colors.grey[700]!.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF49D86A).withOpacity(0.15)
                    : Colors.grey[600]!.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isEnabled ? const Color(0xFF49D86A) : Colors.grey[500],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? Colors.white : Colors.grey[500],
                        ),
                      ),
                      if (!isEnabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isEnabled
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[500]!.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isEnabled)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showUnderConstructionDialog(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Under Construction',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          '$method is currently under construction.\n\nPlease use Email verification instead.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                color: const Color(0xFF49D86A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
