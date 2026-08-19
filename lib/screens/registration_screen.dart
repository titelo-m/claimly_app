import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();
  String? _selectedGender;
  String? _selectedEmploymentStatus;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _idValidationMessage = '';
  bool _isIdValid = false;
  String _phoneValidationMessage = '';
  bool _isPhoneValid = false;
  String _emailValidationMessage = '';
  bool _isEmailValid = false;
  String _passwordStrengthMessage = '';
  Color _passwordStrengthColor = Colors.grey;
  String _confirmPasswordMessage = '';
  bool _doPasswordsMatch = false;
  
  // Auto-filled fields from ID
  String _extractedGender = '';
  String _extractedDateOfBirth = '';
  bool _isIdDataExtracted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF081814),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Back button - goes directly to landing page
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/landing'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
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
            ),

            const SizedBox(height: 8),

            // Get covered title with Space Grotesk font
            Text(
              'Get covered',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              'No credit check. No medical questionnaire. Under 3 minutes.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Card containing form fields
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2A22).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[600]!.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full name',
                      hint: 'Thandi Mokoena',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // SA ID number with real-time validation and auto-fill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SA ID number',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _idController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          onChanged: (value) {
                            setState(() {
                              _validateSAIDRealtime(value);
                              if (_isIdValid && value.length == 13) {
                                _extractDataFromID(value);
                              } else {
                                _isIdDataExtracted = false;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: '13 digits',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            counterText: '',
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your SA ID number';
                            }
                            if (value.length != 13) {
                              return 'ID number must be exactly 13 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'ID number must contain only digits';
                            }
                            if (!_validateSAID(value)) {
                              return 'Please enter a valid SA ID number';
                            }
                            return null;
                          },
                        ),
                        if (_idController.text.isNotEmpty && !_isIdValid)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              _idValidationMessage,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (_isIdDataExtracted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF49D86A),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '✓ ID verified',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF49D86A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.white38,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Gender: $_extractedGender',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: Colors.white38,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DOB: $_extractedDateOfBirth',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cellphone number - shows error while typing, disappears when valid
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cellphone number',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          onChanged: (value) {
                            setState(() {
                              _validatePhoneRealtime(value);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: '082 123 4567',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            counterText: '',
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your cellphone number';
                            }
                            final cleaned = value.replaceAll(' ', '');
                            if (cleaned.length != 10) {
                              return 'Phone number must be exactly 10 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
                              return 'Phone number must contain only digits';
                            }
                            return null;
                          },
                        ),
                        if (_phoneController.text.isNotEmpty && !_isPhoneValid)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              _phoneValidationMessage,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email address - shows error while typing, disappears when valid
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email address',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              _validateEmailRealtime(value);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            counterText: '',
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        if (_emailController.text.isNotEmpty && !_isEmailValid)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              _emailValidationMessage,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Password with strength indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                          obscureText: !_isPasswordVisible,
                          onChanged: (value) {
                            setState(() {
                              _checkPasswordStrength(value);
                              _checkPasswordsMatch();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'At least 6 characters',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            counterText: '',
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (_passwordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: _passwordStrengthColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _passwordStrengthMessage,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _passwordStrengthColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password with real-time match validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm password',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                          obscureText: !_isConfirmPasswordVisible,
                          onChanged: (value) {
                            setState(() {
                              _checkPasswordsMatch();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            counterText: '',
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF6B6B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        if (_confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              _confirmPasswordMessage,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _doPasswordsMatch
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),

                    // Section: Additional Information
                    Text(
                      'Additional Information',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Helps us assess your risk and price your cover accurately.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date of birth - auto-filled from ID
                    _buildReadOnlyField(
                      controller: _dobController,
                      label: 'Date of birth',
                      hint: 'Auto-filled from ID',
                      isFilled: _isIdDataExtracted,
                    ),
                    const SizedBox(height: 16),

                    // Gender - auto-filled from ID
                    _buildReadOnlyField(
                      controller: TextEditingController(
                        text: _extractedGender,
                      ),
                      label: 'Gender',
                      hint: 'Auto-filled from ID',
                      isFilled: _isIdDataExtracted,
                    ),
                    const SizedBox(height: 16),

                    // Employment status
                    _buildDropdownField(
                      label: 'Employment status',
                      hint: 'Select employment status',
                      value: _selectedEmploymentStatus,
                      items: const [
                        'Employed',
                        'Self-employed',
                        'Informal / Piece work',
                        'Unemployed',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEmploymentStatus = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your employment status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation (optional)',
                      hint: 'e.g. Domestic worker, Street vendor',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _monthlyIncomeController,
                      label: 'Monthly income - R (optional)',
                      hint: 'e.g. 4500',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),

                    // Section: Next of Kin
                    Text(
                      'Next of Kin (optional)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Who should we contact if you make a claim?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nextOfKinNameController,
                      label: 'Next of kin full name',
                      hint: 'Full name',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nextOfKinPhoneController,
                      label: 'Next of kin phone number',
                      hint: '0821234567',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // optional
                        }
                        final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned)) {
                          return 'Enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create my account button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF49D86A),
                  foregroundColor: const Color.fromARGB(255, 36, 35, 35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 36, 35, 35),
                          ),
                        ),
                      )
                    : Text(
                        'Create my account',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 36, 35, 35),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Or divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continue with Google - with Google Sign-In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _handleGoogleSignIn();
                },
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                label: Text(
                  'Continue with Google',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Already have an account - navigate to login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Sign in',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF49D86A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Extract gender and date of birth from SA ID
  void _extractDataFromID(String id) {
    if (id.length != 13) return;

    try {
      // Extract date of birth (YYMMDD)
      final year = int.parse(id.substring(0, 2));
      final month = int.parse(id.substring(2, 4));
      final day = int.parse(id.substring(4, 6));

      // Determine full year (1900s or 2000s)
      final currentYear = DateTime.now().year;
      final currentCentury = currentYear ~/ 100;
      int fullYear = (currentCentury * 100) + year;

      // If the resulting date is in the future, use previous century
      final possibleDate = DateTime(fullYear, month, day);
      if (possibleDate.isAfter(DateTime.now())) {
        fullYear -= 100;
      }

      final date = DateTime(fullYear, month, day);
      if (date.year != fullYear || date.month != month || date.day != day) {
        return;
      }

      // Format date
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      _extractedDateOfBirth =
          '${day.toString().padLeft(2, '0')} ${months[month - 1]} ${fullYear}';
      
      // Set DOB controller
      _dobController.text =
          '$fullYear-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      // Extract gender from ID (digits 7-10)
      final genderDigits = int.tryParse(id.substring(6, 10)) ?? 0;
      _extractedGender = genderDigits >= 5000 ? 'Male' : 'Female';
      
      // Auto-select gender
      _selectedGender = _extractedGender;

      _isIdDataExtracted = true;

      // Update the UI
      setState(() {});
    } catch (_) {
      _isIdDataExtracted = false;
    }
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isFilled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.inter(
            color: isFilled ? Colors.white : Colors.white54,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
            ),
            filled: true,
            fillColor: isFilled
                ? const Color(0xFF49D86A).withOpacity(0.08)
                : Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isFilled
                    ? const Color(0xFF49D86A).withOpacity(0.3)
                    : Colors.grey[600]!.withOpacity(0.35),
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isFilled
                    ? const Color(0xFF49D86A)
                    : Colors.grey[600]!.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: isFilled
                ? Icon(
                    Icons.check_circle,
                    color: const Color(0xFF49D86A),
                    size: 18,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          style: GoogleFonts.inter(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
            ),
            suffixIcon: suffixIcon,
            counterText: '',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF6B6B),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.hasError
                      ? const Color(0xFFFF6B6B)
                      : Colors.grey[600]!.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0D2A22),
                  hint: Text(
                    hint,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                  icon: Icon(
                    Icons.expand_more,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    onChanged(newValue);
                    state.didChange(newValue);
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF49D86A),
              onPrimary: Colors.black,
              surface: Color(0xFF0D2A22),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF081814),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  // SA ID Number Validation (Luhn algorithm variant for SA IDs)
  bool _validateSAID(String id) {
    if (id.length != 13) return false;
    if (!RegExp(r'^[0-9]+$').hasMatch(id)) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = id.length - 1; i >= 0; i--) {
      int n = int.parse(id[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  // Real-time SA ID validation
  void _validateSAIDRealtime(String value) {
    if (value.isEmpty) {
      setState(() {
        _idValidationMessage = '';
        _isIdValid = false;
      });
      return;
    }

    if (value.length < 13) {
      setState(() {
        _idValidationMessage = 'Enter 13 digits';
        _isIdValid = false;
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      setState(() {
        _idValidationMessage = 'Only numbers allowed';
        _isIdValid = false;
      });
      return;
    }

    if (_validateSAID(value)) {
      setState(() {
        _idValidationMessage = '';
        _isIdValid = true;
      });
    } else {
      setState(() {
        _idValidationMessage = 'Invalid SA ID number';
        _isIdValid = false;
      });
    }
  }

  // Real-time Phone validation - only show errors, hide when valid
  void _validatePhoneRealtime(String value) {
    final cleaned = value.replaceAll(' ', '');

    if (value.isEmpty) {
      setState(() {
        _phoneValidationMessage = '';
        _isPhoneValid = false;
      });
      return;
    }

    if (cleaned.length < 10) {
      setState(() {
        _phoneValidationMessage = 'Enter 10 digits';
        _isPhoneValid = false;
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      setState(() {
        _phoneValidationMessage = 'Only numbers allowed';
        _isPhoneValid = false;
      });
      return;
    }

    if (cleaned.length == 10) {
      setState(() {
        _phoneValidationMessage = '';
        _isPhoneValid = true;
      });
    }
  }

  // Real-time Email validation - only show errors, hide when valid
  void _validateEmailRealtime(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailValidationMessage = '';
        _isEmailValid = false;
      });
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (emailRegex.hasMatch(value)) {
      setState(() {
        _emailValidationMessage = '';
        _isEmailValid = true;
      });
    } else {
      setState(() {
        _emailValidationMessage = 'Enter a valid email address';
        _isEmailValid = false;
      });
    }
  }

  // Password strength checker
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrengthMessage = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    int strength = 0;
    Color color = Colors.red;

    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (password.length < 6) {
      setState(() {
        _passwordStrengthMessage = 'Too short';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    if (strength <= 2) {
      setState(() {
        _passwordStrengthMessage = 'Weak';
        _passwordStrengthColor = Colors.red;
      });
    } else if (strength <= 4) {
      setState(() {
        _passwordStrengthMessage = 'Medium';
        _passwordStrengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrengthMessage = 'Strong';
        _passwordStrengthColor = Colors.green;
      });
    }
  }

  // Check if passwords match
  void _checkPasswordsMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordMessage = '';
        _doPasswordsMatch = false;
      });
      return;
    }

    if (password == confirmPassword) {
      setState(() {
        _confirmPasswordMessage = 'Passwords match ✓';
        _doPasswordsMatch = true;
      });
    } else {
      setState(() {
        _confirmPasswordMessage = 'Passwords do not match';
        _doPasswordsMatch = false;
      });
    }
  }

  // Google Sign-In handler
  void _handleGoogleSignIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D2A22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.construction, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text(
              'Coming soon',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Google Sign-Up isn\'t connected yet.\n\nPlease register with your email for now.',
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

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Register with backend
        final response = await ApiService.register({
          'fullName': _nameController.text,
          'idNumber': _idController.text,
          'phoneNumber': _phoneController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'dateOfBirth': _dobController.text,
          'gender': _selectedGender,
          'employmentStatus': _selectedEmploymentStatus,
          'occupation': _occupationController.text.trim().isEmpty
              ? null
              : _occupationController.text.trim(),
          'monthlyIncome': _monthlyIncomeController.text.trim().isEmpty
              ? null
              : num.tryParse(_monthlyIncomeController.text.trim()),
          'nextOfKinName': _nextOfKinNameController.text.trim().isEmpty
              ? null
              : _nextOfKinNameController.text.trim(),
          'nextOfKinPhone': _nextOfKinPhoneController.text.trim().isEmpty
              ? null
              : _nextOfKinPhoneController.text.trim(),
        });

        // 2. Save token and user data
        if (response['token'] != null) {
          await StorageService.saveToken(response['token']);
          await StorageService.saveUserEmail(_emailController.text);
        }

        if (mounted) {
          Provider.of<UserModel>(context, listen: false).login(
            _nameController.text,
            _idController.text,
            _phoneController.text,
            _emailController.text,
          );
        }

        // 3. Navigate to verification method selection
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/verification_method',
            arguments: {
              'phoneNumber': _phoneController.text,
              'email': _emailController.text,
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinPhoneController.dispose();
    super.dispose();
  }
}