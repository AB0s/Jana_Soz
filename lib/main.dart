import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/error_text.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/routes.dart';
import 'package:jana_soz/theme/pallete.dart';
import 'package:jana_soz/features/auth/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:routemaster/routemaster.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authStateChangeProvider).when(
        data: (data) => MaterialApp.router(
              title: 'Flutter Demo',
              theme: Pallete.darkModeAppTheme,
              routerDelegate: RoutemasterDelegate(
                  routesBuilder: (context) => loggedOutRoute),
              routeInformationParser: const RoutemasterParser(),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
