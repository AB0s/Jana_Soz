import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jana_soz/core/constants/constants.dart';
import 'package:jana_soz/core/failure.dart';
import 'package:jana_soz/core/providers/storage_repository_provider.dart';
import 'package:jana_soz/core/utils.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/features/community/repository/communitory_repository.dart';
import 'package:jana_soz/models/community_model.dart';
import 'package:jana_soz/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});
// A provider named `userCommunitiesProvider` that exposes a stream of user communities.
// It uses the `StreamProvider` class to provide the stream of data.
// The stream is obtained by calling the `getUserCommunities` method on the `communityControllerProvider` notifier.
// The `communityControllerProvider` is accessed using the `ref.watch` function.
// This provider is responsible for supplying the user communities data to the consumer widgets in the application.
// Usage: `final userCommunities = useProvider(userCommunitiesProvider);`

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});
// A provider named `communityControllerProvider` that provides an instance of the `CommunityController` class.
// It uses the `StateNotifierProvider` class to create the provider.
// The `CommunityController` class requires two dependencies: `communityRepository` and `storageRepository`, which are obtained by accessing the respective providers using `ref.watch`.
// The `CommunityController` instance is created with the obtained dependencies and the `ref` parameter.
// This provider is responsible for managing the state and handling the logic related to community operations in the social network app.
// Usage: `final communityController = useProvider(communityControllerProvider);`

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});
// A provider named `getCommunityByNameProvider` that exposes a stream of a community based on its name.
// It uses the `StreamProvider.family` constructor to provide a family of providers.
// The `ref` parameter and a `String` parameter `name` are passed to the provider.
// The stream is obtained by calling the `getCommunityByName` method on the `communityControllerProvider` notifier.
// The `communityControllerProvider` is accessed using the `ref.watch` function.
// This provider allows dynamically fetching a community by its name and provides the community data as a stream to the consumer widgets.
// Usage: `final communityStream = useProvider(getCommunityByNameProvider('communityName'));`

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});
// A provider named `searchCommunityProvider` that exposes a stream of search results for a given query.
// It uses the `StreamProvider.family` constructor to provide a family of providers.
// The `ref` parameter and a `String` parameter `query` are passed to the provider.
// The stream is obtained by calling the `searchCommunity` method on the `communityControllerProvider` notifier.
// The `communityControllerProvider` is accessed using the `ref.watch` function.
// This provider allows dynamically searching for communities based on a query and provides the search results as a stream to the consumer widgets.
// Usage: `final searchResults = useProvider(searchCommunityProvider('searchQuery'));`

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});
// A provider named `getCommunityPostsProvider` that exposes a stream of posts for a specific community.
// It uses the `StreamProvider.family` constructor to provide a family of providers.
// The `ref` parameter and a `String` parameter `name` are passed to the provider.
// The stream is obtained by calling the `getCommunityPosts` method on the `communityControllerProvider` notifier.
// The `communityControllerProvider` is accessed using the `ref.read` function.
// This provider allows dynamically fetching posts for a specific community and provides the post data as a stream to the consumer widgets.
// Usage: `final communityPostsStream = useProvider(getCommunityPostsProvider('communityName'));`

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }
  // The `createCommunity` method in the `CommunityController` class.
  // It takes two parameters: `name` of type `String` representing the name of the community, and `context` of type `BuildContext`.
  // It is responsible for creating a new community with the given name.

  // The method sets the state to `true` to indicate that the creation process has started.
  // It obtains the user's ID from the `userProvider` using `_ref.read(userProvider)?.uid`.
  // Then it creates a new `Community` object with the provided `name`, default `banner` and `avatar`, and sets the `members` and `mods` to contain the user's ID.

  // After creating the `community`, it calls the `createCommunity` method on the `_communityRepository` to create the community.
  // The state is set to `false` to indicate that the creation process is completed.

  // The method handles the result using the `fold` method. If the result is a `left` value (Failure), it shows a snackbar with the error message using the `showSnackBar` method.
  // If the result is a `right` value (Success), it shows a snackbar with a success message and navigates back using `Routemaster.of(context).pop()`.

  // This method allows the creation of a new community and provides appropriate feedback using snackbar messages.
  // Usage: `communityController.createCommunity('communityName', context);`

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully!');
      } else {
        showSnackBar(context, 'Community joined successfully!');
      }
    });
  }
  // The `joinCommunity` method in the `CommunityController` class.
  // It takes two parameters: `community` of type `Community` and `context` of type `BuildContext`.
  // It is responsible for allowing a user to join or leave a community.

  // It first obtains the current user from the `userProvider` using `_ref.read(userProvider)`.
  // Then it declares a variable `res` of type `Either<Failure, void>` to store the result of the operation.

  // If the `community` already contains the user in its `members` list, it calls the `leaveCommunity` method on the `_communityRepository` to leave the community.
  // Otherwise, it calls the `joinCommunity` method on the `_communityRepository` to join the community.

  // The method then handles the result using the `fold` method. If the result is a `left` value (Failure), it shows a snackbar with the error message using the `showSnackBar` method.
  // If the result is a `right` value (Success), it shows a snackbar with the appropriate message based on whether the user joined or left the community.

  // This method allows a user to join or leave a community and provides appropriate feedback using snackbar messages.
  // Usage: `communityController.joinCommunity(community, context);`

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }
  // The `getCommunityByName` method in the `_communityRepository` class.
  // It takes a `String` parameter `name` representing the name of the community.
  // It returns a stream of a single `Community` object.
  // The stream is obtained by calling the `getCommunityByName` method on the `_communityRepository`.
  // This method retrieves a specific community by its name from the community repository.
  // Usage: `final communityStream = communityRepository.getCommunityByName('communityName');`

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }
  // The `getCommunityByName` method in the `CommunityController` class.
  // It takes a `String` parameter `name` representing the name of the community.
  // It returns a stream of a single `Community` object.
  // The stream is obtained by calling the `getCommunityByName` method on the `_communityRepository`.
  // This method retrieves a specific community by its name from the community repository.
  // Usage: `final communityStream = communityController.getCommunityByName('communityName');`

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null || profileWebFile != null) {
      // communities/profile/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
            (l) => showSnackBar(context, l.message),
            (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null || bannerWebFile != null) {
      // communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
            (l) => showSnackBar(context, l.message),
            (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => Routemaster.of(context).pop(),
    );
  }
  // The `editCommunity` method in the `CommunityController` class.
  // It takes several parameters including `profileFile`, `bannerFile`, `profileWebFile`, `bannerWebFile`, `context`, and `community`.
  // It is responsible for editing a community by updating its profile and banner images and other details.

  // The method sets the state to `true` to indicate that the editing process has started.
  // If `profileFile` or `profileWebFile` is provided, it stores the file in the storage repository using the `_storageRepository.storeFile` method.
  // If successful, it updates the `community` object with the new avatar (profile image).
  // If `bannerFile` or `bannerWebFile` is provided, it stores the file in the storage repository for the community's banner image.
  // If successful, it updates the `community` object with the new banner image.

  // After updating the profile and banner images, it calls the `editCommunity` method on the `_communityRepository` to save the changes to the community details.
  // The state is set to `false` to indicate that the editing process is completed.
  // If successful, it navigates back using `Routemaster.of(context).pop()`.
  // If any errors occur during the process, it shows a snackbar with the error message using the `showSnackBar` method.

  // This method handles the editing of a community, including updating its profile and banner images and other details.
  // Usage: `communityController.editCommunity(profileFile: file, context: context, community: community);`

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }
  // The `searchCommunity` method in the `CommunityController` class.
  // It takes a `String` parameter `query` representing the search query.
  // It returns a stream of a list of `Community` objects.
  // The stream is obtained by calling the `searchCommunity` method on the `_communityRepository`.
  // This method performs a search for communities based on the provided query in the community repository.
  // Usage: `final searchResultsStream = communityController.searchCommunity('searchQuery');`

  void addMods(String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => Routemaster.of(context).pop(),
    );
  }
  // The `addMods` method in the `CommunityController` class.
  // It takes three parameters: `communityName` (String) representing the name of the community, `uids` (List<String>) representing the user IDs of the moderators to be added, and `context` (BuildContext) for showing a snackbar and navigating.

  // The method calls the `addMods` method on the `_communityRepository`, passing the `communityName` and `uids`.
  // It awaits the result and handles it using the `fold` method.
  // If the result is a left value (Failure), it shows a snackbar with the error message using the `showSnackBar` method.
  // If the result is a right value (Success), it navigates back using `Routemaster.of(context).pop()`.

  // This method adds moderators to a community in the social network app and handles success or failure scenarios.
  // Usage: `communityController.addMods('communityName', ['uid1', 'uid2'], context);`

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }
  // The `getCommunityPosts` method in the `CommunityController` class.
  // It takes a `String` parameter `name` representing the name of the community.
  // It returns a stream of a list of `Post` objects.
  // The stream is obtained by calling the `getCommunityPosts` method on the `_communityRepository`.
  // This method retrieves the posts for a specific community from the community repository.
  // Usage: `final postsStream = communityController.getCommunityPosts('communityName');`
}