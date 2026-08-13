import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _claimUpdates = true;
  bool _paymentReminders = true;
  bool _generalAnnouncements = true;
  bool _isEditing = false;
  
  // Profile Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  String _selectedProvince = '';
  
  // Bank Controllers
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  String _selectedAccountType = '';

  final List<String> _provinces = [
    'Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal',
    'Limpopo', 'Mpumalanga', 'Northern Cape', 'North West', 'Western Cape'
  ];
  
  final List<String> _accountTypes = ['Cheque', 'Savings', 'Current', 'Transmission'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    
    _fullNameController.text = userModel.fullName;
    _phoneController.text = userModel.phoneNumber;
    _altPhoneController.text = userModel.altPhone;
    _emailController.text = userModel.email;
    _streetController.text = userModel.street;
    _cityController.text = userModel.city;
    _postalCodeController.text = userModel.postalCode;
    _selectedProvince = userModel.province;
    
    _bankNameController.text = userModel.bankName;
    _accountHolderController.text = userModel.accountHolder;
    _accountNumberController.text = userModel.accountNumber;
    _branchCodeController.text = userModel.branchCode;
    _selectedAccountType = userModel.accountType;
  }

  void _saveUserData() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    
    userModel.updateProfile(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      altPhone: _altPhoneController.text.trim(),
      email: _emailController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      province: _selectedProvince,
      postalCode: _postalCodeController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountHolder: _accountHolderController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      branchCode: _branchCodeController.text.trim(),
      accountType: _selectedAccountType,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'Profile',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_isEditing) {
                          _saveUserData();
                        }
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      child: Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF49D86A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () {
                        _showLogoutConfirmation(context);
                      },
                      icon: Icon(
                        LucideIcons.log_out,
                        color: Colors.white.withOpacity(0.6),
                        size: 18,
                      ),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ],
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

                  // CARD 1: Personal Information
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          icon: LucideIcons.user,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Mobile Number',
                          controller: _phoneController,
                          icon: LucideIcons.phone,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Alternative Number (Optional)',
                          controller: _altPhoneController,
                          icon: LucideIcons.phone,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Email Address',
                          controller: _emailController,
                          icon: LucideIcons.mail,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Street Address',
                          controller: _streetController,
                          icon: LucideIcons.building_2,  // Fixed
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'City',
                          controller: _cityController,
                          icon: LucideIcons.map_pin,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildDropdown(
                          label: 'Province',
                          value: _selectedProvince,
                          items: _provinces,
                          icon: LucideIcons.compass,
                          enabled: _isEditing,
                          onChanged: (value) {
                            setState(() {
                              _selectedProvince = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Postal Code',
                          controller: _postalCodeController,
                          icon: LucideIcons.mailbox,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        
                        // SA ID (read-only, locked)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SA ID Number',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    Text(
                                      userModel.idNumber.isNotEmpty ? userModel.idNumber : 'Not provided',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock_outline,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Locked',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.orange[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARD 2: Banking Details
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Banking Details',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildField(
                          label: 'Bank Name',
                          controller: _bankNameController,
                          icon: LucideIcons.landmark,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Account Holder',
                          controller: _accountHolderController,
                          icon: LucideIcons.user,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Account Number',
                          controller: _accountNumberController,
                          icon: LucideIcons.hash,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildField(
                          label: 'Branch Code',
                          controller: _branchCodeController,
                          icon: LucideIcons.code,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildDropdown(
                          label: 'Account Type',
                          value: _selectedAccountType,
                          items: _accountTypes,
                          icon: LucideIcons.list,
                          enabled: _isEditing,
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notifications Section
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSwitch(
                          title: 'Claim updates',
                          subtitle: 'Get notified when your claim status changes',
                          value: _claimUpdates,
                          onChanged: (value) {
                            setState(() {
                              _claimUpdates = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        _buildSwitch(
                          title: 'Payment reminders',
                          subtitle: 'Get notified before your debit order is processed',
                          value: _paymentReminders,
                          onChanged: (value) {
                            setState(() {
                              _paymentReminders = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        _buildSwitch(
                          title: 'General announcements',
                          subtitle: 'Get updates about new products and features',
                          value: _generalAnnouncements,
                          onChanged: (value) {
                            setState(() {
                              _generalAnnouncements = value;
                            });
                          },
                        ),
                      ],
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
        currentIndex: 3,
        selectedItemColor: const Color(0xFF49D86A),
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/claims');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/payments');
          } else if (index == 3) {
            return;
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF49D86A),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: keyboardType,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.white.withOpacity(0.1),
          height: 1,
          thickness: 0.5,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF49D86A),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButton<String>(
                value: value.isEmpty ? null : value,
                isExpanded: true,
                underline: Divider(
                  color: Colors.white.withOpacity(0.1),
                  height: 1,
                  thickness: 0.5,
                ),
                dropdownColor: const Color(0xFF0D2A22),
                style: GoogleFonts.inter(
                  color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                icon: Icon(
                  Icons.expand_more,
                  color: enabled ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                  size: 20,
                ),
                hint: Text(
                  'Select $label',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 15,
                  ),
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF49D86A),
        ),
      ],
    );
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
    _fullNameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }
}