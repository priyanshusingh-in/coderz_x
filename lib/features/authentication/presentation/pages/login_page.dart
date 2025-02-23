import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/service_locator.dart';
import '../bloc/auth_bloc.dart';
import '../../../jobs/presentation/pages/job_listing_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _navigateToNextScreen(context, state);
          } else if (state is AuthError) {
            _showErrorDialog(context, state.error.message);
          }
        },
        builder: (context, state) {
          return _buildLoginContent(context, state);
        },
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, AuthState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/coderz_x_logo.png',
              height: 150,
            ),
            const SizedBox(height: 32),
            Text(
              'Welcome to CoderzX',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (state is AuthLoading)
              const CircularProgressIndicator()
            else ...[
              _buildSignInButton(
                context,
                text: 'Sign in with Google',
                onPressed: () => _signInWithGoogle(context),
                icon: 'assets/icons/google_icon.svg',
              ),
              const SizedBox(height: 16),
              _buildSignInButton(
                context,
                text: 'Sign in with Apple',
                onPressed: () => _signInWithApple(context),
                icon: 'assets/icons/apple_icon.svg',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    required String icon,
  }) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(icon, height: 24),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }

  void _signInWithGoogle(BuildContext context) {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  void _signInWithApple(BuildContext context) {
    context.read<AuthBloc>().add(AppleSignInRequested());
  }

  void _navigateToNextScreen(BuildContext context, AuthAuthenticated? state) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => state?.displayName == null
            ? const ProfilePage()
            : const JobListingPage(),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
