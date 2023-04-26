import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/utils.dart';
import 'package:jana_soz/features/auth/repository/auth_repository.dart';
import 'package:jana_soz/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider((ref) =>
    AuthController(authRepository: ref.watch(authRepositoryProvider), ref: ref));

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,super(false);

  void signInWithGoogle(BuildContext context) async {
    state=true;
    final user = await _authRepository.signInWithGoogle();
    state=false;
    user.fold(
        (l) => showSnackBar(context, l),
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }
}