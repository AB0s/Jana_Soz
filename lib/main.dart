import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/error_text.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/firebase_options.dart';
import 'package:jana_soz/generated/codegen_loader.g.dart';
import 'package:jana_soz/models/user_model.dart';
import 'package:jana_soz/router.dart';
import 'package:jana_soz/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ru'),Locale('de')],
        path: 'assets/translations',
        fallbackLocale: Locale('ru'),
        assetLoader: CodegenLoader(),
        child: const ProviderScope(
      child: MyApp(),
        ),
      ),
      );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
      data: (data) => MaterialApp.router(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: 'Jana Soz',
        theme: ref.watch(themeNotifierProvider),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (context) {
            if (data != null) {
              getData(ref, data);
              if (userModel != null) {
                return loggedInRoute;
              }
            }
            return loggedOutRoute;
          },
        ),
        routeInformationParser: const RoutemasterParser(),
      ),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
      loading: () => const Loader(),
    );
  }
}