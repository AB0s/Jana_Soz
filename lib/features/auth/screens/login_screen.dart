import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/core/common/sign_in_button.dart';
import 'package:jana_soz/core/constants/constants.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/responsive/responsive.dart';

class login_screen extends ConsumerWidget {
  const login_screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Constants.logoPath,
          height: 60,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Qonaq retynde kiru',
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
            'Kir de, qyzyqta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              Constants.loginEmotePath,
              height: 350,
            ),
          ),
          const SizedBox(height: 40),
          const Responsive(child: SignInButton()),
        ],
      ),
    );
  }
}