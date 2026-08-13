import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 39, 31),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            children: const [
              TextSpan(text: 'Claim', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'ly', style: TextStyle(color: Color(0xFF49D86A))),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF49D86A),
                foregroundColor: const Color.fromARGB(255, 30, 30, 30),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get covered',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: height * 0.9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF000000), Color(0xFF081814), Color(0xFF07130F)],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 0.6,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF49D86A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF49D86A).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'COVER FROM R79 / MONTH',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF49D86A),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(text: "When you can't work, "),
                            TextSpan(
                              text: 'Claimly pays',
                              style: TextStyle(
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 57, 101, 81),
                                      Color(0xFF49D86A),
                                    ],
                                  ).createShader(const Rect.fromLTWH(0, 0, 220, 0)),
                              ),
                            ),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Income protection and car excess cover built for South African workers who don\'t get sick leave. Register in under 3 minutes, claim from your phone, get paid in 48 hours.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/registration');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF49D86A),
                                foregroundColor: const Color.fromARGB(255, 36, 35, 35),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Get covered',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/plans');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade600, width: 1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'See the plans',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildUserChip('Car owners'),
                            _buildUserChip('Retail workers & cashiers'),
                            _buildUserChip('Domestic workers'),
                            _buildUserChip('Street vendors'),
                            _buildUserChip('Self-employed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Who we are section - darker background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              color: const Color(0xFF061D18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Who we are',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Claimly is a South African micro-insurance app. No brokers, no paperwork queues, no call centre hold music. You subscribe on your phone, upload your documents when something happens, and track your money end to end.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.78),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 1000) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildFeatureItem(
                                    icon: Icons.phone_android,
                                    title: 'Sign up in 3 minutes',
                                    subtitle: 'Name, SA ID and cellphone. No credit check, no medical questionnaire.',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFeatureItem(
                                    icon: Icons.timer,
                                    title: '48-hour turnaround',
                                    subtitle: 'Complete, valid claims are targeted for payment within 48 hours.',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFeatureItem(
                                    icon: Icons.payments,
                                    title: 'Paid straight to you',
                                    subtitle: 'Benefit paid into your bank account or mobile wallet.',
                                  ),
                                ),
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureItem(
                                icon: Icons.phone_android,
                                title: 'Sign up in 3 minutes',
                                subtitle: 'Name, SA ID and cellphone. No credit check, no medical questionnaire.',
                              ),
                              _buildFeatureItem(
                                icon: Icons.timer,
                                title: '48-hour turnaround',
                                subtitle: 'Complete, valid claims are targeted for payment within 48 hours.',
                              ),
                              _buildFeatureItem(
                                icon: Icons.payments,
                                title: 'Paid straight to you',
                                subtitle: 'Benefit paid into your bank account or mobile wallet.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Products Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: isDark ? const Color(0xFF04110D) : Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Our products',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProductCard(
                    title: 'Income Protection',
                    subtitle: "Money in your pocket when you can't work",
                    description: 'A monthly cash benefit paid to you if illness, injury or retrenchment stops your income. Built for workers who don\'t get sick leave.',
                    bronzePrice: 'R99',
                    silverPrice: 'R189',
                    goldPrice: 'R329',
                    context: context,
                  ),
                  const SizedBox(height: 20),
                  _buildProductCard(
                    title: 'Excess Fee Cover',
                    subtitle: 'We pay the excess when you claim on your car',
                    description: "Covers the insurance excess you'd normally pay out of pocket after an accident, theft or damage claim on your vehicle.",
                    bronzePrice: 'R79',
                    silverPrice: 'R149',
                    goldPrice: 'R259',
                    context: context,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FD8A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4FD8A4).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FD8A4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No smartphone? No problem.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dial *120*252645# from any phone to check your cover and start a claim.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[300] : Colors.grey[600],
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
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF49D86A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF49D86A),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String subtitle,
    required String description,
    required String bronzePrice,
    required String silverPrice,
    required String goldPrice,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2A22).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Title
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle in green
          Text(
            subtitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: const Color(0xFF49D86A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          
          // Bronze, Silver, Gold Row - Transparent cards with white text
          Row(
            children: [
              _buildTierCard('BRONZE', bronzePrice, context),
              const SizedBox(width: 10),
              _buildTierCard('SILVER', silverPrice, context),
              const SizedBox(width: 10),
              _buildTierCard('GOLD', goldPrice, context),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Compare tiers button - centered, dim white with padded container
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cover_selection');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Compare tiers →',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(String tier, String price, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.grey[600]!.withOpacity(0.4),
            width: 0.6,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              tier,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'per month',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}