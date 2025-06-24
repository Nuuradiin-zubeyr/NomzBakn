import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/accounts_screen.dart';
import '../screens/main/transactions_screen.dart';
import '../screens/main/cards_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/main/settings_screen.dart';

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
    initialLocation: onboarding,
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
    ],
  );
} 