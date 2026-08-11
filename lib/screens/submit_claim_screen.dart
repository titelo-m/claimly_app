import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class SubmitClaimScreen extends StatefulWidget {
  const SubmitClaimScreen({super.key});

  @override
  State<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends State<SubmitClaimScreen> {
  String _selectedClaimType = '';
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _uploadedFiles = [];
  bool _isSubmitting = false;

  final Map<String, List<String>> _requiredDocuments = {
    'Illness': [
      'Medical report or doctor\'s certificate',
      'Treatment records (if available)',
    ],
    'Injury / Accident': [
      'Medical assessment',
      'Accident report',
      'Doctor\'s confirmation of inability to work',
    ],
    'Retrenchment': [
      'Retrenchment letter',
      'Employer confirmation or termination documentation',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF081814),
      body: Column(
        children: [
          // Sticky Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF081814),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title on the left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit a claim',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'We aim to pay valid claims within 48 hours',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                // Logout Button
                TextButton.icon(
                  onPressed: () {
                    _showLogoutConfirmation(context);
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // What happened?
                  Text(
                    'What happened?',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Claim type selection - full width cards
                  _buildClaimTypeCard(
                    title: 'Illness',
                    subtitle: 'Doctor-certified condition stopping you from working',
                    isSelected: _selectedClaimType == 'Illness',
                    onTap: () {
                      setState(() {
                        _selectedClaimType = 'Illness';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildClaimTypeCard(
                    title: 'Injury / Accident',
                    subtitle: 'Workplace or personal accident',
                    isSelected: _selectedClaimType == 'Injury / Accident',
                    onTap: () {
                      setState(() {
                        _selectedClaimType = 'Injury / Accident';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildClaimTypeCard(
                    title: 'Retrenchment',
                    subtitle: 'Involuntary job loss',
                    isSelected: _selectedClaimType == 'Retrenchment',
                    onTap: () {
                      setState(() {
                        _selectedClaimType = 'Retrenchment';
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Tell us what happened',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe the illness, accident or retrenchment in your own words.',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[600]!.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF49D86A),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Documents needed (if claim type selected) - with card
                  if (_selectedClaimType.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2A22).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[600]!.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Documents needed for a ${_selectedClaimType.toLowerCase()} claim',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._requiredDocuments[_selectedClaimType]!.map((doc) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '• ',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  Text(
                                    doc,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // File upload - full width
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[600]!.withOpacity(0.35),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Take a photo or upload files',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG or PDF · max 10MB each · up to 5 files',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Upload button - centered
                        Center(
                          child: ElevatedButton(
                            onPressed: _uploadedFiles.length < 5 ? _pickFiles : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF49D86A),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Add files',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        
                        // File list
                        if (_uploadedFiles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ..._uploadedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    file.path.split('/').last,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _uploadedFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _uploadedFiles.isEmpty ? null : _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF49D86A),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              'Submit claim',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  if (_uploadedFiles.isEmpty && _selectedClaimType.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Attach at least one supporting document to submit.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF212121),
        currentIndex: 1,
        selectedItemColor: const Color(0xFF49D86A),
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            return;
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

  Widget _buildClaimTypeCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2A22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF49D86A).withOpacity(0.8)
                : Colors.grey[600]!.withOpacity(0.35),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected 
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null) {
      setState(() {
        _uploadedFiles.add(File(image.path));
      });
    }
  }

  Future<void> _submitClaim() async {
    if (_selectedClaimType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a claim type',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please describe what happened',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.addClaim(
      Claim(
        id: 'CLM-26-${1000 + userModel.claims.length + 1}',
        type: _selectedClaimType,
        description: _descriptionController.text,
        status: 'SUBMITTED',
        date: DateTime.now(),
        documents: _uploadedFiles.map((f) => f.path.split('/').last).toList(),
      ),
    );

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Claim submitted successfully!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _selectedClaimType = '';
      _descriptionController.clear();
      _uploadedFiles.clear();
    });

    Navigator.pushReplacementNamed(context, '/claims');
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Logout',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final userModel = Provider.of<UserModel>(context, listen: false);
              userModel.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/landing');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}