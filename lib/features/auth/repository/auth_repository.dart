import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jana_soz/core/constants/constants.dart';
import 'package:jana_soz/core/constants/firebase_constants.dart';
import 'package:jana_soz/core/failure.dart';
import 'package:jana_soz/core/providers/firebase_providers.dart';
import 'package:jana_soz/core/type_defs.dart';
import 'package:jana_soz/models/user_model.dart';

final authRepositoryProvider = Provider(
      (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();
  // The AuthRepository class responsible for handling authentication-related operations in the social network app.
  // It takes the following required parameters: FirebaseFirestore instance (`firestore`), FirebaseAuth instance (`auth`), and GoogleSignIn instance (`googleSignIn`).

  // The `_auth` property is assigned with the `auth` parameter.
  // The `_firestore` property is assigned with the `firestore` parameter.
  // The `_googleSignIn` property is assigned with the `googleSignIn` parameter.

  // The `get _users` method returns the Firestore collection reference for the "users" collection, using `_firestore.collection(FirebaseConstants.usersCollection)`.

  // This repository class provides the necessary dependencies and methods to interact with Firebase for authentication and user data management in the social network app.
  // Usage: `AuthRepository(firestore: myFirestore, auth: myAuth, googleSignIn: myGoogleSignIn)`

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final googleAuth = await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential = await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // A method `signInWithGoogle` within the AuthRepository class that handles the sign-in with Google functionality.
  // It takes a boolean parameter `isFromLogin` to indicate whether the sign-in is from the login screen or account linking.
  // It performs the following steps:
  // 1. If the platform is web (using `kIsWeb` flag), it uses GoogleAuthProvider to sign in with Google via a popup.
  //    It adds a scope for read-only access to Google Contacts.
  //    The user credential is obtained using `_auth.signInWithPopup(googleProvider)`.
  // 2. If the platform is not web, it uses `_googleSignIn` to initiate the Google Sign-In flow.
  //    The obtained GoogleSignInAccount is used to get the Google authentication details.
  //    The GoogleAuthProvider credential is created with the obtained access token and ID token.
  //    If `isFromLogin` is true, `_auth.signInWithCredential` is used to sign in with the credential.
  //    If `isFromLogin` is false, `_auth.currentUser!.linkWithCredential` is used to link the credential to the current user.
  //    The user credential is assigned to `userCredential`.
  // 3. If `additionalUserInfo.isNewUser` is true, it means it's a new user, so it creates a new UserModel instance with the obtained user details.
  //    It sets the name, profilePic, banner, uid, isAuthenticated, karma, and awards properties accordingly.
  //    The new user data is written to the Firestore `_users` collection using the user's UID as the document ID.
  //    The UserModel is assigned to `userModel`.
  // 4. If `additionalUserInfo.isNewUser` is false, it means it's an existing user, so it fetches the user data using the `getUserData` method.
  //    The first element of the fetched user data stream is assigned to `userModel`.
  // 5. Finally, it returns a `right` Either containing the `userModel` if the sign-in and data handling are successful.
  // 6. If any FirebaseException occurs during the sign-in or data handling, it throws the exception message.
  // 7. If any other exception occurs, it returns a `left` Either containing a Failure object with the error message.
  // Usage: `await _authRepository.signInWithGoogle(true);` or `await _authRepository.signInWithGoogle(false);`

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );
      // Creates a new instance of the UserModel class named `userModel`.
      // It initializes the properties of the UserModel object with the following values:
      // - name: 'Guest'
      // - profilePic: Constants.avatarDefault
      // - banner: Constants.bannerDefault
      // - uid: userCredential.user!.uid
      // - isAuthenticated: false
      // - karma: 0
      // - awards: []
      // This UserModel instance represents a guest user with default values.
      // Usage: `UserModel userModel = UserModel(...);`

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // A method `signInAsGuest` within the AuthRepository class that handles the sign-in as a guest functionality.
  // It performs the following steps:
  // 1. Calls `_auth.signInAnonymously()` to sign in anonymously and obtain the user credential.
  // 2. Creates a new instance of the UserModel class named `userModel` with default guest user values.
  // 3. Writes the `userModel` data to the Firestore `_users` collection using the user's UID as the document ID.
  // 4. Returns a `right` Either containing the `userModel` if the sign-in and data writing are successful.
  // 5. If any FirebaseException occurs during the sign-in or data writing, it throws the exception message.
  // 6. If any other exception occurs, it returns a `left` Either containing a Failure object with the error message.
  // Usage: `await _authRepository.signInAsGuest();`

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
  // A method `getUserData` within the UserRepository class that retrieves user data based on the provided user ID.
  // It takes the `uid` (user ID) as a parameter.
  // It uses the `_users` Firestore collection to get a document snapshot for the specified user ID.
  // The method then maps the snapshot to a UserModel instance using the `fromMap` constructor of the UserModel class.
  // The method returns a stream of UserModel representing the user data.
  // Usage: `userRepository.getUserData('user123').listen((userData) => ...);`

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  // A method `logOut` within the AuthRepository class that handles the logout functionality.
  // It performs the sign-out operations for both Google Sign-In and the general authentication provider.
  // First, it calls `_googleSignIn.signOut()` to sign out from the Google Sign-In.
  // Then, it calls `_auth.signOut()` to perform the general sign-out operation.
  // This method is typically called when the user chooses to log out of the application.
  // Usage: `_authRepository.logOut();`
}