import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

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
                onTap: () => Navigator.pushReplacementNamed(context, '/landing'),
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

                    // SA ID number with real-time validation
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
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                                color: _doPasswordsMatch ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                      ],
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
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In successful!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.login(
        _nameController.text,
        _idController.text,
        _phoneController.text,
        _emailController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
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
    super.dispose();
  }
}