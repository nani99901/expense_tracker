import 'package:flutter/material.dart';

import 'package:expense_tracker/features/auth_onboarding/presentation/pages/landing_screen.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/onboarding.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/signup_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/verfication_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/pin_setup_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/account_setup.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/add_wallet_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/success_page.dart';
import 'package:expense_tracker/features/auth_onboarding/presentation/pages/pin_unlock_page.dart';
import 'package:expense_tracker/features/home/presentation/pages/app_shell.dart';

class AppRoutes {
  static const landing = '/landing';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const verification = '/verification';
  static const pinSetup = '/pin-setup';
  static const accountSetup = '/account-setup';
  static const addWallet = '/add-wallet';
  static const success = '/success';
  static const unlock = '/unlock';
  static const home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.verification:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => VerificationPage(email: email));
      case AppRoutes.pinSetup:
        return MaterialPageRoute(builder: (_) => const PinSetupPage());
      case AppRoutes.accountSetup:
        return MaterialPageRoute(builder: (_) => const AccountSetup());
      case AppRoutes.addWallet:
        return MaterialPageRoute(builder: (_) => const AddWallet());
      case AppRoutes.success:
        return MaterialPageRoute(builder: (_) => const SuccessPage());
      case AppRoutes.unlock:
        return MaterialPageRoute(builder: (_) => const PinUnlockPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const AppShell());
      default:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
    }
  }
}
