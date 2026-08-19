import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideStartRoute();
  }

  Future<void> _decideStartRoute() async {
    // Keep the splash on screen briefly regardless of outcome, so it
    // doesn't just flash for returning users on a fast connection.
    final minSplash = Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();
    String nextRoute = '/landing';

    if (token != null && token.isNotEmpty) {
      try {
        final profile = await ApiService.getProfile(token);
        if (mounted) {
          Provider.of<UserModel>(context, listen: false)
              .updateFromApi(profile);
        }
        final role = profile['role'];
        final isStaff = role == 'ADMIN' || role == 'SUPER_ADMIN';
        nextRoute = isStaff ? '/admin_dashboard' : '/dashboard';
      } catch (_) {
        // Token is invalid/expired - fall back to landing and clear it
        // so the user isn't stuck in a broken "half logged in" state.
        await StorageService.deleteToken();
        nextRoute = '/landing';
      }
    }

    await minSplash;
    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081814),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Text
            RichText(
              text: TextSpan(
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(text: 'Claim', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'ly', style: TextStyle(color: Color(0xFF49D86A))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Get covered',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF49D86A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}