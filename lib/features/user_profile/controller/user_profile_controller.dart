import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/enums/enums.dart';
import 'package:jana_soz/core/providers/storage_repository_provider.dart';
import 'package:jana_soz/core/utils.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/models/post_model.dart';
import 'package:jana_soz/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:jana_soz/features/user_profile/repository/user_profile_repository.dart';

// Provider for the UserProfileController
final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

// Provider for getting user posts by their UID
final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  // Edit the user's community profile
  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    // Update the user's profile picture if a new file is provided
    if (profileFile != null || profileWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    // Update the user's banner image if a new file is provided
    if (bannerFile != null || bannerWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    // Update the user's name
    user = user.copyWith(name: name);
    
    // Edit the user's profile using the UserProfileRepository
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // Update the user data in the userProvider
        _ref.read(userProvider.notifier).update((state) => user);
        // Navigate back
        Routemaster.of(context).pop();
      },
    );
  }

  // Get user posts by their UID
  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  // Update user karma
  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }
}
