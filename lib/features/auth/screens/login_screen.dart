import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/core/common/sign_in_button.dart';
import 'package:jana_soz/core/constants/constants.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/responsive/responsive.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          height: 40,
        ),
        actions: [
          TextButton(
            onPressed: () => signInAsGuest(ref, context),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Dive into anything',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              Constants.loginEmotePath,
              height: 200,
            ),
          ),
          const SizedBox(height: 20),
          const Responsive(child: SignInButton()),
        ],
      ),
    );
  }
}
// The LoginScreen widget represents the login screen of the social network app.
// It extends the ConsumerWidget class, indicating that it consumes data from
// providers.

// The signInAsGuest method triggers the sign-in as a guest functionality.
// It uses the ref parameter to access the authControllerProvider.notifier and
// calls the signInAsGuest method on it, passing the context.

// The build method builds the UI of the login screen. It watches the
// authControllerProvider to get the isLoading value.

// The UI includes an AppBar with a logo image and a "Skip" button.
// The button triggers the signInAsGuest method. The body of the screen shows
// a loader if isLoading is true, indicating that authentication is in progress.
// Otherwise, it displays a column with a title, an image, and a sign-in button.

// The LoginScreen widget integrates with the authControllerProvider
// to handle user authentication and provides the user interface for the
// login screen.