import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class CoverSelectionScreen extends StatefulWidget {
  const CoverSelectionScreen({super.key});

  @override
  State<CoverSelectionScreen> createState() => _CoverSelectionScreenState();
}

class _CoverSelectionScreenState extends State<CoverSelectionScreen> {
  String _selectedProduct = 'Income Protection';
  String _selectedTier = 'BRONZE';
  String _selectedPaymentMethod = 'Debit order';
  bool _hasExistingCover = false;

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    _hasExistingCover = userModel.hasCover;
    if (_hasExistingCover) {
      _selectedProduct = userModel.selectedProduct.isNotEmpty 
          ? userModel.selectedProduct 
          : 'Income Protection';
      _selectedTier = userModel.selectedTier.isNotEmpty 
          ? userModel.selectedTier 
          : 'BRONZE';
      _selectedPaymentMethod = userModel.paymentMethod.isNotEmpty 
          ? userModel.paymentMethod 
          : 'Debit order';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncomeProtection = _selectedProduct == 'Income Protection';

    return Scaffold(
      backgroundColor: const Color(0xFF081814),
      body: Column(
        children: [
          // Sticky Header - only Back and Logout
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
                // Back button only
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
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
                  const SizedBox(height: 16),
                  
                  // Your cover title (scrollable)
                  Text(
                    'Your cover',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose or change your plan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current policies (if user has existing cover)
                  if (_hasExistingCover) ...[
                    Text(
                      'Current policies',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userModel.selectedProduct,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF49D86A).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF49D86A).withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF49D86A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${userModel.selectedTier} TIER',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF49D86A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'R${userModel.selectedTier == 'BRONZE' ? '99' : userModel.selectedTier == 'SILVER' ? '189' : '329'}/month · Next debit 05 Sept 2026',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Cancel button - smaller
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _showCancelConfirmation(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Cancel this policy',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Pick a product
                  Text(
                    'Pick a product',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Product selection cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          title: 'Income Protection',
                          subtitle: "Money in your pocket when you can't work",
                          isSelected: _selectedProduct == 'Income Protection',
                          onTap: () {
                            setState(() {
                              _selectedProduct = 'Income Protection';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildProductCard(
                          title: 'Excess Fee Cover',
                          subtitle: 'We pay the excess when you claim on your car',
                          isSelected: _selectedProduct == 'Excess Fee Cover',
                          onTap: () {
                            setState(() {
                              _selectedProduct = 'Excess Fee Cover';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pick a tier
                  Text(
                    'Pick a tier',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tier options based on selected product
                  if (isIncomeProtection) ...[
                    _buildTierOption(
                      tier: 'BRONZE',
                      price: 'R 99',
                      benefit: 'R 2 500 benefit · Up to 3 monthly payouts',
                      isSelected: _selectedTier == 'BRONZE',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'BRONZE';
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTierOption(
                      tier: 'SILVER',
                      price: 'R 189',
                      benefit: 'R 5 000 benefit · Up to 6 monthly payouts',
                      isSelected: _selectedTier == 'SILVER',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'SILVER';
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTierOption(
                      tier: 'GOLD',
                      price: 'R 329',
                      benefit: 'R 9 000 benefit · Up to 9 monthly payouts',
                      isSelected: _selectedTier == 'GOLD',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'GOLD';
                        });
                      },
                    ),
                  ] else ...[
                    _buildTierOption(
                      tier: 'BRONZE',
                      price: 'R 79',
                      benefit: 'R 3 500 benefit · 1 excess payout per 12 months',
                      isSelected: _selectedTier == 'BRONZE',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'BRONZE';
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTierOption(
                      tier: 'SILVER',
                      price: 'R 149',
                      benefit: 'R 7 500 benefit · 2 excess payouts per 12 months',
                      isSelected: _selectedTier == 'SILVER',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'SILVER';
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTierOption(
                      tier: 'GOLD',
                      price: 'R 259',
                      benefit: 'R 15 000 benefit · Unlimited excess payouts per 12 months',
                      isSelected: _selectedTier == 'GOLD',
                      onTap: () {
                        setState(() {
                          _selectedTier = 'GOLD';
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Payment method
                  Text(
                    'Payment method',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildPaymentOption(
                    title: 'Debit order',
                    subtitle: 'Deducted monthly from your bank account',
                    isSelected: _selectedPaymentMethod == 'Debit order',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Debit order';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    title: 'EasyPay',
                    subtitle: 'Pay cash at any till point with your EasyPay number',
                    isSelected: _selectedPaymentMethod == 'EasyPay',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'EasyPay';
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Review my cover button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        userModel.setCover(
                          _selectedProduct,
                          _selectedTier,
                          _selectedPaymentMethod,
                        );
                        Navigator.pushNamed(context, '/confirm_cover');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF49D86A),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Review my cover',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
        currentIndex: 0,
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

  Widget _buildProductCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2A22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.8)
                : Colors.grey[600]!.withOpacity(0.35),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected 
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierOption({
    required String tier,
    required String price,
    required String benefit,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF0D2A22).withOpacity(0.8)
              : const Color(0xFF0D2A22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF49D86A).withOpacity(0.6)
                : Colors.grey[600]!.withOpacity(0.35),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    benefit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF0D2A22).withOpacity(0.8)
              : const Color(0xFF0D2A22).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF49D86A).withOpacity(0.6)
                : Colors.grey[600]!.withOpacity(0.35),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
          ],
        ),
      ),
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

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Cancel Policy',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your policy? This action cannot be undone.',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Policy cancelled successfully',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.8),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}