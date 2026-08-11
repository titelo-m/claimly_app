import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class ClaimDetailScreen extends StatelessWidget {
  const ClaimDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final claim = ModalRoute.of(context)!.settings.arguments as Claim;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get status color
    Color getStatusColor() {
      switch (claim.status) {
        case 'SUBMITTED':
          return Colors.orange;
        case 'UNDER REVIEW':
          return Colors.blue;
        case 'APPROVED':
          return Colors.green;
        case 'PAID':
          return const Color(0xFF00D4AA);
        case 'DECLINED':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // Get status steps
    List<Map<String, String>> getStatusSteps() {
      final steps = [
        {'label': 'Submitted', 'time': claim.date.toLocal().toString().substring(0, 16)},
        {'label': 'Under Review', 'time': ''},
        {'label': 'Approved', 'time': ''},
        {'label': 'Paid', 'time': ''},
      ];

      // Update based on current status
      if (claim.status == 'SUBMITTED') {
        steps[0]['time'] = claim.date.toLocal().toString().substring(0, 16);
      } else if (claim.status == 'UNDER REVIEW') {
        steps[0]['time'] = claim.date.toLocal().toString().substring(0, 16);
        steps[1]['time'] = DateTime.now().toLocal().toString().substring(0, 16);
      } else if (claim.status == 'APPROVED' || claim.status == 'PAID') {
        steps[0]['time'] = claim.date.toLocal().toString().substring(0, 16);
        steps[1]['time'] = DateTime.now().subtract(const Duration(hours: 2)).toLocal().toString().substring(0, 16);
        steps[2]['time'] = DateTime.now().subtract(const Duration(hours: 1)).toLocal().toString().substring(0, 16);
      }
      if (claim.status == 'PAID') {
        steps[3]['time'] = DateTime.now().toLocal().toString().substring(0, 16);
      }

      return steps;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              claim.id,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              claim.type,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted ${claim.date.day.toString().padLeft(2, '0')}/${claim.date.month.toString().padLeft(2, '0')}/${claim.date.year}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: getStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    claim.status,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress tracker
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F4A43) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: getStatusSteps().asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isCompleted = step['time']!.isNotEmpty;
                  final isLast = index == getStatusSteps().length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle and line
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted 
                                  ? const Color(0xFF00D4AA)
                                  : isDark 
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                              border: Border.all(
                                color: isCompleted 
                                    ? const Color(0xFF00D4AA)
                                    : isDark 
                                        ? Colors.grey[600]!
                                        : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: GoogleFonts.inter(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                              color: isCompleted 
                                  ? const Color(0xFF00D4AA)
                                  : isDark 
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['label']!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted 
                                    ? (isDark ? Colors.white : Colors.black)
                                    : isDark 
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                              ),
                            ),
                            if (step['time']!.isNotEmpty)
                              Text(
                                step['time']!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // What you told us
            Text(
              'What you told us',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F4A43) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Text(
                claim.description.isNotEmpty ? claim.description : 'A lot happened.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Documents
            if (claim.documents.isNotEmpty) ...[
              Text(
                'Documents',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...claim.documents.map((doc) => Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F4A43) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Color(0xFF4FD8A4),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            doc,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.download,
                            size: 20,
                          ),
                          onPressed: () {
                            // Download document
                          },
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // History
            Text(
              'History',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F4A43) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history,
                    color: Color(0xFF4FD8A4),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submitted',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${claim.date.day.toString().padLeft(2, '0')}/${claim.date.month.toString().padLeft(2, '0')}/${claim.date.year}, ${claim.date.hour.toString().padLeft(2, '0')}:${claim.date.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Query on WhatsApp button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://wa.me/27761234567?text=Hi%20Claimly%2C%20I%20have%20a%20query%20about%20claim%20${claim.id}',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(
                  Icons.chat,
                  color: Color(0xFF25D366),
                ),
                label: Text(
                  'Query this claim on WhatsApp',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color(0xFF25D366),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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
}