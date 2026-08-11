import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

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
            
            // Back button with hover effect
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
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
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Plans & pricing title
            Text(
              'Plans & pricing',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            
            Text(
              'Two products, three tiers each. Change tier or product any time before your first debit order with no penalty.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Income Protection Section
            _buildProductSection(
              title: 'Income Protection',
              subtitle: "Money in your pocket when you can't work",
              tiers: [
                TierData(
                  name: 'BRONZE',
                  displayName: 'Bronze',
                  price: 'R 99',
                  benefit: 'R 2 500',
                  benefitDetail: 'Up to 3 monthly payouts',
                  color: const Color(0xFFCD7F32),
                  features: [
                    'Doctor-certified illness',
                    'Injury or workplace accident',
                    'Retrenchment / involuntary job loss',
                    'Payout within 48 hours of approval',
                  ],
                  exclusions: [
                    'Resignation or dismissal for misconduct',
                    'Claims inside the 9-month waiting period',
                    'Pre-existing conditions declared after signup',
                  ],
                ),
                TierData(
                  name: 'SILVER',
                  displayName: 'Silver',
                  price: 'R 189',
                  benefit: 'R 5 000',
                  benefitDetail: 'Up to 6 monthly payouts',
                  color: Colors.grey[400]!,
                  features: [
                    'Everything in Bronze',
                    'Higher monthly benefit',
                    'Priority claims review',
                    'Free policy document downloads',
                  ],
                  exclusions: [
                    'Resignation or dismissal for misconduct',
                    'Claims inside the 9-month waiting period',
                    'Pre-existing conditions declared after signup',
                  ],
                ),
                TierData(
                  name: 'GOLD',
                  displayName: 'Gold',
                  price: 'R 329',
                  benefit: 'R 9 000',
                  benefitDetail: 'Up to 9 monthly payouts',
                  color: const Color(0xFFFFD700),
                  features: [
                    'Everything in Silver',
                    'Highest monthly benefit',
                    'Dedicated claims agent on WhatsApp',
                    'Family notification on claim outcome',
                  ],
                  exclusions: [
                    'Resignation or dismissal for misconduct',
                    'Claims inside the 9-month waiting period',
                    'Pre-existing conditions declared after signup',
                    'Self-inflicted injury',
                  ],
                ),
              ],
              context: context,
            ),

            const SizedBox(height: 32),

            // Excess Fee Cover Section
            _buildProductSection(
              title: 'Excess Fee Cover',
              subtitle: 'We pay the excess when you claim on your car',
              tiers: [
                TierData(
                  name: 'BRONZE',
                  displayName: 'Bronze',
                  price: 'R 79',
                  benefit: 'R 3 500',
                  benefitDetail: '1 excess payout per 12 months',
                  color: const Color(0xFFCD7F32),
                  features: [
                    'Accident excess',
                    'Theft & hijacking excess',
                    'Hail and weather damage excess',
                    'Direct payment to your panel beater or you',
                  ],
                  exclusions: [
                    'Driving without a valid licence',
                    'Driving under the influence',
                    'Claims inside the 9-month waiting period',
                  ],
                ),
                TierData(
                  name: 'SILVER',
                  displayName: 'Silver',
                  price: 'R 149',
                  benefit: 'R 7 500',
                  benefitDetail: '2 excess payouts per 12 months',
                  color: Colors.grey[400]!,
                  features: [
                    'Everything in Bronze',
                    'Higher excess limit',
                    'Windscreen excess included',
                    'Priority claims review',
                  ],
                  exclusions: [
                    'Driving without a valid licence',
                    'Driving under the influence',
                    'Unroadworthy vehicle claims',
                  ],
                ),
                TierData(
                  name: 'GOLD',
                  displayName: 'Gold',
                  price: 'R 259',
                  benefit: 'R 15 000',
                  benefitDetail: 'Unlimited excess payouts per 12 months',
                  color: const Color(0xFFFFD700),
                  features: [
                    'Everything in Silver',
                    'Highest excess limit',
                    'Car hire contribution while repairs happen',
                    'Dedicated claims agent on WhatsApp',
                  ],
                  exclusions: [
                    'Driving without a valid licence',
                    'Driving under the influence',
                    'Unroadworthy vehicle claims',
                  ],
                ),
              ],
              context: context,
            ),

            const SizedBox(height: 24),

            // Waiting period notice - grey text with grey background
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

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF212121),
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/landing');
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

  Widget _buildProductSection({
    required String title,
    required String subtitle,
    required List<TierData> tiers,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF49D86A),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        ...tiers.map((tier) => _buildTierCard(tier, context)),
      ],
    );
  }

  Widget _buildTierCard(TierData tier, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2A22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.4),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tier.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tier.color,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tier.price,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'per month',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Benefit amount
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Benefit amount',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tier.benefit,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      tier.benefitDetail,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Features (green checkmarks)
          ...tier.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF49D86A),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // Exclusions (grey text with grey icons)
          ...tier.exclusions.map((exclusion) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.grey[500],
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      exclusion,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 20),

          // Choose button - same green color for all, no icon, bold text
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cover_selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF49D86A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Choose ${tier.displayName}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TierData {
  final String name;
  final String displayName;
  final String price;
  final String benefit;
  final String benefitDetail;
  final Color color;
  final List<String> features;
  final List<String> exclusions;

  TierData({
    required this.name,
    required this.displayName,
    required this.price,
    required this.benefit,
    required this.benefitDetail,
    required this.color,
    required this.features,
    required this.exclusions,
  });
}