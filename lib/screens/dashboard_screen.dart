import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentTime = '';
  bool _isLoading = true;
  List<dynamic> _recentClaims = [];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _fetchUserData();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getToken();
      if (token != null) {
        final profile = await ApiService.getProfile(token);
        if (!mounted) return;
        final userModel = Provider.of<UserModel>(context, listen: false);
        // Update user model with real data
        userModel.updateFromApi(profile);

        final claims = await ApiService.getClaims(token);
        if (!mounted) return;
        setState(() => _recentClaims = claims);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final hasCover = userModel.hasCover;
    final firstName = userModel.fullName.isNotEmpty
        ? userModel.fullName.split(' ').first
        : 'there';

    final recentClaims = _recentClaims.take(5).toList();

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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF49D86A).withOpacity(0.15),
                        backgroundImage: userModel.profilePictureUrl.isNotEmpty
                            ? NetworkImage(
                                '${ApiService.mediaBaseUrl}${userModel.profilePictureUrl}')
                            : null,
                        child: userModel.profilePictureUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFF49D86A),
                                size: 22,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi $firstName',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your Claimly cover',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Updated $_currentTime',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _updateTime();
                              _fetchUserData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Refreshed!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Refresh',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (!hasCover)
                      _buildEmptyCoverCard(context)
                    else if (userModel.isCoverPending)
                      _buildPendingCoverCard(context, userModel)
                    else
                      _buildActiveCoverCard(context, userModel),

                    const SizedBox(height: 24),

                    // Rest of your dashboard code...
                    _buildRecentClaimsSection(context, recentClaims),
                    const SizedBox(height: 32),
                    _buildUSSDInfo(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF49D86A),
        child: const Icon(Icons.chat_bubble, color: Colors.black),
      ),
      bottomNavigationBar: _buildBottomNavBar(0, context),
    );
  }

  // Add the rest of your build methods here (they remain the same)
  Widget _buildRecentClaimsSection(
      BuildContext context, List<dynamic> recentClaims) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent claims',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/claims');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF49D86A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentClaims.isEmpty)
          _buildEmptyClaims()
        else
          ...recentClaims.map((claim) => _buildClaimItem(claim)),
      ],
    );
  }

  Widget _buildEmptyClaims() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'No claims yet.',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "If something happens, submit a claim and we'll target payment within 48 hours.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimItem(dynamic claim) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/claim_detail',
          arguments: claim['claimReference'],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim['claimReference'] ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  claim['claimType'] ?? 'Claim',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  claim['submittedAt'] != null
                      ? _formatDate(DateTime.parse(claim['submittedAt']))
                      : 'Recent',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: claim['status'] == 'SUBMITTED'
                    ? Colors.orange.withOpacity(0.2)
                    : claim['status'] == 'UNDER_REVIEW'
                        ? Colors.blue.withOpacity(0.2)
                        : claim['status'] == 'APPROVED'
                            ? Colors.green.withOpacity(0.2)
                            : claim['status'] == 'PAID'
                                ? const Color(0xFF49D86A).withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: claim['status'] == 'SUBMITTED'
                      ? Colors.orange.withOpacity(0.3)
                      : claim['status'] == 'UNDER_REVIEW'
                          ? Colors.blue.withOpacity(0.3)
                          : claim['status'] == 'APPROVED'
                              ? Colors.green.withOpacity(0.3)
                              : claim['status'] == 'PAID'
                                  ? const Color(0xFF49D86A).withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                (claim['status'] ?? 'SUBMITTED').toString().replaceAll('_', ' '),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: claim['status'] == 'SUBMITTED'
                      ? Colors.orange
                      : claim['status'] == 'UNDER_REVIEW'
                          ? Colors.blue
                          : claim['status'] == 'APPROVED'
                              ? Colors.green
                              : claim['status'] == 'PAID'
                                  ? const Color(0xFF49D86A)
                                  : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildPendingCoverCard(BuildContext context, UserModel userModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2A22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
          const SizedBox(height: 12),
          Text(
            'Cover pending approval',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${userModel.selectedProduct} · ${userModel.selectedTier} tier',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "An admin is reviewing your cover selection. You'll get an email as soon as it's approved.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCoverCard(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final isPending = userModel.isPendingApproval;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2A22).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? Colors.orange.withOpacity(0.35)
              : Colors.grey[600]!.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isPending) ...[
            Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
            const SizedBox(height: 12),
          ],
          Text(
            isPending ? 'Your account is pending approval' : "You're not covered yet",
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPending
                ? "An admin is reviewing your details. You'll be able to choose your cover once your account is approved."
                : "Pick a plan and you'll be protected from your first debit order.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPending
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/cover_selection');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF49D86A),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isPending ? 'Awaiting approval' : 'Choose my cover',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/submit_claim');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49D86A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit a claim',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cover_selection');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.6),
                    side: BorderSide(
                      color: Colors.grey[600]!.withOpacity(0.4),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Policy details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCoverCard(BuildContext context, UserModel userModel) {
    // Get benefit detail based on product and tier
    String getBenefitDetail() {
      if (userModel.selectedProduct == 'Income Protection') {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return 'Up to 3 monthly payouts';
          case 'SILVER':
            return 'Up to 6 monthly payouts';
          case 'GOLD':
            return 'Up to 9 monthly payouts';
          default:
            return 'Up to 3 monthly payouts';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return '1 excess payout per 12 months';
          case 'SILVER':
            return '2 excess payouts per 12 months';
          case 'GOLD':
            return 'Unlimited excess payouts per 12 months';
          default:
            return '1 excess payout per 12 months';
        }
      }
    }

    // Get benefit amount based on product and tier
    String getBenefitAmount() {
      if (userModel.selectedProduct == 'Income Protection') {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return 'R 2 500';
          case 'SILVER':
            return 'R 5 000';
          case 'GOLD':
            return 'R 9 000';
          default:
            return 'R 2 500';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return 'R 3 500';
          case 'SILVER':
            return 'R 7 500';
          case 'GOLD':
            return 'R 15 000';
          default:
            return 'R 3 500';
        }
      }
    }

    // Get monthly premium
    String getMonthlyPremium() {
      if (userModel.selectedProduct == 'Income Protection') {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return 'R99';
          case 'SILVER':
            return 'R189';
          case 'GOLD':
            return 'R329';
          default:
            return 'R99';
        }
      } else {
        switch (userModel.selectedTier) {
          case 'BRONZE':
            return 'R79';
          case 'SILVER':
            return 'R149';
          case 'GOLD':
            return 'R259';
          default:
            return 'R79';
        }
      }
    }

    return Container(
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
                userModel.selectedProduct.isNotEmpty
                    ? userModel.selectedProduct
                    : 'Income Protection',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 16),

          // 4 cards in 2x2 grid
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
                  label: 'Benefit amount',
                  value: getBenefitAmount(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'Next debit',
                  value: '05 Sept 2026',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  label: 'Payment method',
                  value: userModel.paymentMethod.isNotEmpty
                      ? userModel.paymentMethod
                      : 'Debit order',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${getBenefitDetail()} · Waiting period ends 08 May 2027',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/submit_claim');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49D86A),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit a claim',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cover_selection');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.6),
                    side: BorderSide(
                      color: Colors.grey[600]!.withOpacity(0.4),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Policy details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value}) {
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

  Widget _buildUSSDInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No data? Dial *120*252645#',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Check your cover and start a claim from any phone, no internet needed.',
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
    );
  }

  Widget _buildBottomNavBar(int currentIndex, BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF212121),
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF49D86A),
      unselectedItemColor: Colors.white.withOpacity(0.5),
      onTap: (index) {
        if (index == 0) return;
        if (index == 1) {
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
            onPressed: () async {
              await StorageService.deleteToken();
              final userModel = Provider.of<UserModel>(context, listen: false);
              userModel.logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/landing');
              }
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
