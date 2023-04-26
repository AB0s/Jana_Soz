import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user=ref.watch(userProvider)!;
    return const Scaffold(
      body: Center(
        child: Text(''),
      ),
    );
  }
}
