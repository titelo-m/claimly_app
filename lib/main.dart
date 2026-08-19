import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/verification_method_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/cover_selection_screen.dart';
import 'screens/confirm_cover_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/claims_screen.dart';
import 'screens/claim_detail_screen.dart';
import 'screens/submit_claim_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Claimly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/verification_method': (context) => const VerificationMethodScreen(),
        '/otp_verification': (context) => const OTPVerificationScreen(),
        '/cover_selection': (context) => const CoverSelectionScreen(),
        '/confirm_cover': (context) => const ConfirmCoverScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/claims': (context) => const ClaimsScreen(),
        '/claim_detail': (context) => const ClaimDetailScreen(),
        '/submit_claim': (context) => const SubmitClaimScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/plans': (context) => const PlansScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/documents': (context) => const DocumentsScreen(),
        '/chat': (context) => const ChatScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LandingScreen(),
        );
      },
    );
  }
}