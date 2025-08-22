import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/landing/landing_screen.dart';
import '../presentation/screens/onboarding/starfield_welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/diet/diet_screen.dart';
import '../presentation/screens/workout/workout_screen.dart';
import '../presentation/screens/hydration/hydration_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Start with the starfield welcome screen
      GoRoute(
          path: '/',
          builder: (context, state) => const StarfieldWelcomeScreen()),

      // Your original landing screen (for auth options)
      GoRoute(
          path: '/landing', builder: (context, state) => const LandingScreen()),

      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/diet',
            builder: (context, state) => const DietScreen(),
          ),
          GoRoute(
            path: '/workout',
            builder: (context, state) => const WorkoutScreen(),
          ),
          GoRoute(
            path: '/hydration',
            builder: (context, state) => const HydrationScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Hydration',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/diet')) return 1;
    if (location.startsWith('/workout')) return 2;
    if (location.startsWith('/hydration')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/diet');
        break;
      case 2:
        context.go('/workout');
        break;
      case 3:
        context.go('/hydration');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
