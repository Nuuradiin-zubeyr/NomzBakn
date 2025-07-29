import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/accounts_screen.dart';
import '../screens/main/transactions_screen.dart';
import '../screens/main/cards_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/main/settings_screen.dart';
import '../screens/main/notifications_screen.dart';
import '../screens/main/transfer_screen.dart';
import '../screens/auth/forget_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/new_password_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/set_pin_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String accounts = '/accounts';
  static const String transactions = '/transactions';
  static const String cards = '/cards';
  static const String profile = '/profile';

  static GoRouter get router => GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // If user is not logged in and trying to access protected routes
      if (!authProvider.isLoggedIn) {
        // Allow access to auth routes
        if (state.matchedLocation == onboarding || 
            state.matchedLocation == login || 
            state.matchedLocation == signup ||
            state.matchedLocation == '/forget-password' ||
            state.matchedLocation == '/reset-password' ||
            state.matchedLocation == '/new-password' ||
            state.matchedLocation == '/verify-email' ||
            state.matchedLocation == '/set-pin') {
          return null; // Allow access
        }
        // Redirect to onboarding for all other routes
        return onboarding;
      }
      
      // If user is logged in and trying to access auth routes
      if (authProvider.isLoggedIn && 
          (state.matchedLocation == onboarding || 
           state.matchedLocation == login || 
           state.matchedLocation == signup)) {
        return dashboard; // Redirect to dashboard
      }
      
      return null; // Allow access
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>;
          return EmailVerificationScreen(userData: userData);
        },
      ),
      GoRoute(
        path: '/set-pin',
        builder: (context, state) => const SetPinScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: accounts,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: transactions,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: cards,
        builder: (context, state) => const CardsScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: '/forget-password',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/new-password',
        builder: (context, state) => const NewPasswordScreen(),
      ),
    ],
  );
} 