import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/utils.dart';
import 'package:jana_soz/features/auth/repository/auth_repository.dart';
import 'package:jana_soz/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
      (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);
// Provider responsible for managing authentication state in the social network app.
// It uses the AuthController class, instantiated with an authRepository obtained from the authRepositoryProvider.
// The AuthController handles authentication logic and state management.
// The bool value represents the current authentication status.
// Usage: final authState = useProvider(authControllerProvider);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});
// Provider that exposes a stream of authentication state changes in the social network app.
// It depends on the authControllerProvider, which provides the AuthController instance.
// The authStateChange stream is obtained from the AuthController's authStateChange property.
// This provider can be used to listen for real-time updates to the authentication state.
// Usage: `final authStateStream = useProvider(authStateChangeProvider);`

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});
// Provider that exposes a stream of user data for a specific user ID in the social network app.
// It is a family provider, allowing dynamic parameterization with the user ID.
// It depends on the authControllerProvider, which provides the AuthController instance.
// The getUserData method is called on the AuthController, passing the user ID as a parameter, to obtain the corresponding user data stream.
// This provider can be used to fetch and listen for real-time updates to user data based on the user ID.
// Usage: `final userDataStream = useProvider(getUserDataProvider('user123'));`

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading
  // The AuthController class responsible for handling authentication logic and state management in the social network app.
  // It takes an instance of AuthRepository and Ref as required parameters.
  // The AuthRepository is responsible for interacting with the authentication backend.
  // The Ref is used to access other providers and services within the controller.
  // The super(false) statement sets the initial state of the controller to "loading" (false).
  // Usage: final authController = AuthController(authRepository: myAuthRepository, ref: myRef);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold(
          (l) => showSnackBar(context, l.message),
          (userModel) => _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }
  // A method `signInWithGoogle` within the AuthController class that handles the sign-in with Google functionality.
  // It takes the `BuildContext` and a boolean `isFromLogin` as parameters.
  // It sets the state to true, indicating that the sign-in process is in progress.
  // It then calls the `_authRepository.signInWithGoogle` method to perform the actual sign-in with Google operation.
  // After the sign-in process completes, the state is set back to false.
  // Depending on the result of the sign-in operation, it either shows a snackbar with an error message (if the sign-in failed),
  // or updates the userProvider with the retrieved user model (if the sign-in succeeded).
  // Usage: `authController.signInWithGoogle(context, true);`

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
          (l) => showSnackBar(context, l.message),
          (userModel) => _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }
  // A method `signInAsGuest` within the AuthController class that handles the sign-in as a guest functionality.
  // It takes the `BuildContext` as a parameter.
  // It sets the state to true, indicating that the sign-in process is in progress.
  // It then calls the `_authRepository.signInAsGuest` method to perform the actual sign-in as a guest operation.
  // After the sign-in process completes, the state is set back to false.
  // Depending on the result of the sign-in operation, it either shows a snackbar with an error message (if the sign-in failed),
  // or updates the userProvider with the retrieved user model (if the sign-in succeeded).
  // Usage: `authController.signInAsGuest(context);`

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
  // A method `getUserData` within the AuthController class that retrieves user data based on the provided user ID.
  // It takes the `uid` (user ID) as a parameter.
  // It calls the `_authRepository.getUserData` method to fetch the user data using the provided user ID.
  // The method returns a stream of UserModel representing the user data.
  // Usage: `authController.getUserData('user123').listen((userData) => ...);`
  void logout() async {
    _authRepository.logOut();
  }
  // A method `logout` within the AuthController class that handles the logout functionality.
  // It calls the `_authRepository.logOut` method to perform the logout operation.
  // This method does not return any value.
  // Usage: `authController.logout();`
}