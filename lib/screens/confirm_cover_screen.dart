import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class ConfirmCoverScreen extends StatelessWidget {
  const ConfirmCoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncomeProtection = userModel.selectedProduct == 'Income Protection';

    // Get benefit details based on product and tier
    String getBenefitAmount() {
      if (isIncomeProtection) {
        switch (userModel.selectedTier) {
          case 'BRONZE': return 'R 2 500';
          case 'SILVER': return 'R 5 000';
          case 'GOLD': return 'R 9 000';
          default: return 'R 2 500';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE': return 'R 3 500';
          case 'SILVER': return 'R 7 500';
          case 'GOLD': return 'R 15 000';
          default: return 'R 3 500';
        }
      }
    }

    String getBenefitDuration() {
      if (isIncomeProtection) {
        switch (userModel.selectedTier) {
          case 'BRONZE': return 'Up to 3 monthly payouts';
          case 'SILVER': return 'Up to 6 monthly payouts';
          case 'GOLD': return 'Up to 9 monthly payouts';
          default: return 'Up to 3 monthly payouts';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE': return '1 excess payout per 12 months';
          case 'SILVER': return '2 excess payouts per 12 months';
          case 'GOLD': return 'Unlimited excess payouts per 12 months';
          default: return '1 excess payout per 12 months';
        }
      }
    }

    String getMonthlyPremium() {
      if (isIncomeProtection) {
        switch (userModel.selectedTier) {
          case 'BRONZE': return 'R99';
          case 'SILVER': return 'R189';
          case 'GOLD': return 'R329';
          default: return 'R99';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE': return 'R79';
          case 'SILVER': return 'R149';
          case 'GOLD': return 'R259';
          default: return 'R79';
        }
      }
    }

    // Get covered items based on product and tier
    List<String> getCoveredItems() {
      if (isIncomeProtection) {
        final items = [
          'Doctor-certified illness',
          'Injury or workplace accident',
          'Retrenchment / involuntary job loss',
          'Payout within 48 hours of approval',
        ];
        if (userModel.selectedTier == 'SILVER' || userModel.selectedTier == 'GOLD') {
          items.insert(0, 'Everything in Bronze');
          items.add('Higher monthly benefit');
          items.add('Priority claims review');
          items.add('Free policy document downloads');
        }
        if (userModel.selectedTier == 'GOLD') {
          items.add('Dedicated claims agent on WhatsApp');
          items.add('Family notification on claim outcome');
        }
        return items;
      } else {
        final items = [
          'Accident excess',
          'Theft & hijacking excess',
          'Hail and weather damage excess',
          'Direct payment to your panel beater or you',
        ];
        if (userModel.selectedTier == 'SILVER' || userModel.selectedTier == 'GOLD') {
          items.insert(0, 'Everything in Bronze');
          items.add('Higher excess limit');
          items.add('Windscreen excess included');
          items.add('Priority claims review');
        }
        if (userModel.selectedTier == 'GOLD') {
          items.add('Car hire contribution while repairs happen');
          items.add('Dedicated claims agent on WhatsApp');
        }
        return items;
      }
    }

    // Get not covered items based on product and tier
    List<String> getNotCoveredItems() {
      final items = [
        'Resignation or dismissal for misconduct',
        'Claims inside the 9-month waiting period',
      ];
      if (isIncomeProtection && userModel.selectedTier == 'GOLD') {
        items.add('Self-inflicted injury');
      }
      if (!isIncomeProtection) {
        items.add('Driving without a valid licence');
        items.add('Driving under the influence');
        if (userModel.selectedTier == 'SILVER' || userModel.selectedTier == 'GOLD') {
          items.add('Unroadworthy vehicle claims');
        }
      }
      return items;
    }

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
                      'You Are Covered',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Confirm your plan',
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
                children: [
                  const SizedBox(height: 20),

                  // Main Card
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
                        // Product name
                        Text(
                          userModel.selectedProduct,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Tier in green - normal font
                        Text(
                          '${userModel.selectedTier} TIER',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF49D86A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4 info cards - 2 on top, 2 on bottom with normal font
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                label: 'Monthly premium',
                                value: getMonthlyPremium(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                label: 'Benefit duration',
                                value: getBenefitDuration(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                label: 'Benefit amount',
                                value: getBenefitAmount(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                label: 'Payment method',
                                value: userModel.paymentMethod,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // What's covered
                        Text(
                          "What's covered",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...getCoveredItems().map((item) => _buildCoveredItem(item)),
                        const SizedBox(height: 16),

                        // What's not covered
                        Text(
                          "What's not covered",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...getNotCoveredItems().map((item) => _buildNotCoveredItem(item)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Waiting period notice - grey card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800]!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[700]!.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'A 9-month waiting period applies from your first successful debit order. Changing tier or product after the first debit order restarts the waiting period on the new plan.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons row - Confirm & Back
                  Row(
                    children: [
                      // Back button - grey background
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm button - green
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/dashboard');
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
                            'Confirm & activate',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildInfoCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoveredItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xFF49D86A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotCoveredItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.cancel,
            color: Colors.grey[500],
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
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
}