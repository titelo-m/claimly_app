import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/cover_selection_screen.dart';
import 'screens/confirm_cover_screen.dart';
import 'screens/submit_claim_screen.dart';
import 'screens/claim_detail_screen.dart';
import 'screens/claims_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/plans_screen.dart';
import 'models/user_model.dart';

void main() {
  runApp(const ClaimlyApp());
}

class ClaimlyApp extends StatelessWidget {
  const ClaimlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: Consumer<UserModel>(
        builder: (context, userModel, child) {
          return MaterialApp(
            title: 'Claimly',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: userModel.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/landing': (context) => const LandingScreen(),
              '/registration': (context) => const RegistrationScreen(),
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/cover_selection': (context) => const CoverSelectionScreen(),
              '/confirm_cover': (context) => const ConfirmCoverScreen(),
              '/submit_claim': (context) => const SubmitClaimScreen(),
              '/claim_detail': (context) => const ClaimDetailScreen(),
              '/claims': (context) => const ClaimsScreen(),
              '/payments': (context) => const PaymentsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/plans': (context) => const PlansScreen(),
            },
          );
        },
      ),
    );
  }
}
