import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jana_soz/core/constants/firebase_constants.dart';
import 'package:jana_soz/core/failure.dart';
import 'package:jana_soz/core/providers/firebase_providers.dart';
import 'package:jana_soz/core/type_defs.dart';
import 'package:jana_soz/models/community_model.dart';
import 'package:jana_soz/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});
// A provider named `communityRepositoryProvider` that provides an instance of the `CommunityRepository` class.
// It uses the `Provider` constructor to define the provider.
// The provider takes a function that receives a `ref` parameter.
// Inside the function, it creates and returns a new instance of `CommunityRepository` by passing the `firestoreProvider` to the constructor.
// The `firestoreProvider` is accessed using the `ref.watch` function.

// This provider is responsible for providing the `CommunityRepository` instance that interacts with the Firestore database to perform community-related operations.
// Usage: `final communityRepository = useProvider(communityRepositoryProvider);`

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }

      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // The `createCommunity` method in the `CommunityRepository` class.
  // It takes a `Community` object as a parameter.
  // It returns a `FutureEither<void>` which represents the success or failure of the operation.

  // The method first checks if a community with the same name already exists by querying the Firestore document using `_communities.doc(community.name).get()`.
  // If the document exists, it throws an error indicating that a community with the same name already exists.

  // If the document doesn't exist, it proceeds to create the community by calling `_communities.doc(community.name).set(community.toMap())`.
  // It uses the `toMap()` method of the `Community` object to convert it to a map representation.

  // If any Firebase-related exceptions occur, it throws the corresponding error message.
  // If any other exceptions occur, it returns a `left` value (Failure) with the error message.

  // This method creates a new community in the Firestore database and handles success and error scenarios.
  // Usage: `communityRepository.createCommunity(community);`

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // The `joinCommunity` method in the `CommunityRepository` class.
  // It takes two parameters: `communityName` of type `String` representing the name of the community, and `userId` of type `String` representing the ID of the user.
  // It returns a `FutureEither<void>` which represents the success or failure of the operation.

  // The method updates the document of the specified community by calling `_communities.doc(communityName).update()` with the field and value to be updated.
  // It uses the `FieldValue.arrayUnion` method to add the `userId` to the `members` array field of the document.

  // If any Firebase-related exceptions occur, it throws the corresponding error message.
  // If any other exceptions occur, it returns a `left` value (Failure) with the error message.

  // This method allows a user to join a community by updating the `members` array field in the Firestore database and handles success and error scenarios.
  // Usage: `communityRepository.joinCommunity('communityName', 'userId');`

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // The `leaveCommunity` method in the `CommunityRepository` class.
  // It takes two parameters: `communityName` of type `String` representing the name of the community, and `userId` of type `String` representing the ID of the user.
  // It returns a `FutureEither<void>` which represents the success or failure of the operation.

  // The method updates the document of the specified community by calling `_communities.doc(communityName).update()` with the field and value to be updated.
  // It uses the `FieldValue.arrayRemove` method to remove the `userId` from the `members` array field of the document.

  // If any Firebase-related exceptions occur, it throws the corresponding error message.
  // If any other exceptions occur, it returns a `left` value (Failure) with the error message.

  // This method allows a user to leave a community by updating the `members` array field in the Firestore database and handles success and error scenarios.
  // Usage: `communityRepository.leaveCommunity('communityName', 'userId');`

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }
  // The `getUserCommunities` method in the `CommunityRepository` class.
  // It takes a `uid` parameter of type `String`, representing the ID of the user.
  // It returns a stream of a list of `Community` objects.

  // The method retrieves communities from the Firestore collection `_communities` where the `members` array field contains the specified `uid`.
  // It uses the `snapshots()` method to listen for real-time updates to the collection.

  // Inside the `map` callback function, it iterates over the `event.docs` and converts each document data to a `Community` object using the `Community.fromMap` method.
  // The `fromMap` method takes a `Map<String, dynamic>` as input and constructs a `Community` object.

  // The method returns a stream that emits a list of `Community` objects whenever there are updates to the collection.

  // This method retrieves and listens to communities that the user is a member of from the Firestore database and converts them to `Community` objects.
  // Usage: `communityRepository.getUserCommunities('userId');`

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }
  // The `getCommunityByName` method in the `CommunityRepository` class.
  // It takes a `name` parameter of type `String`, representing the name of the community.
  // It returns a stream of a single `Community` object.

  // The method retrieves a specific community document from the Firestore collection `_communities` by calling `_communities.doc(name)`.
  // It uses the `snapshots()` method to listen for real-time updates to the document.

  // Inside the `map` callback function, it converts the document data to a `Community` object using the `Community.fromMap` method.
  // The `fromMap` method takes a `Map<String, dynamic>` as input and constructs a `Community` object.

  // The method returns a stream that emits a single `Community` object whenever there are updates to the community document.

  // This method retrieves and listens to a specific community document from the Firestore database and converts it to a `Community` object.
  // Usage: `communityRepository.getCommunityByName('communityName');`

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // The `editCommunity` method in the `CommunityRepository` class.
  // It takes a `community` parameter of type `Community`, representing the community to be edited.
  // It returns a `FutureEither<void>` which represents the success or failure of the operation.

  // The method updates the document of the specified community by calling `_communities.doc(community.name).update()` with the updated data.
  // It passes the `toMap()` method of the `community` object to update the document fields based on the provided data.

  // If any Firebase-related exceptions occur, it throws the corresponding error message.
  // If any other exceptions occur, it returns a `left` value (Failure) with the error message.

  // This method edits a community by updating its document in the Firestore database and handles success and error scenarios.
  // Usage: `communityRepository.editCommunity(community);`

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
      'name',
      isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
      isLessThan: query.isEmpty
          ? null
          : query.substring(0, query.length - 1) +
          String.fromCharCode(
            query.codeUnitAt(query.length - 1) + 1,
          ),
    )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities.add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }
  // The `searchCommunity` method in the `CommunityRepository` class.
  // It takes a `query` parameter of type `String`, representing the search query.
  // It returns a stream of a list of `Community` objects.

  // The method performs a Firestore query on the `_communities` collection.
  // It uses the `where` method to filter the documents based on the `name` field.
  // If the `query` is empty, it retrieves all communities. Otherwise, it performs a range query using `isGreaterThanOrEqualTo` and `isLessThan` to match communities whose names are within a certain range.

  // The `snapshots()` method is called to listen for real-time updates to the collection.

  // Inside the `map` callback function, it iterates over the `event.docs` and converts each document data to a `Community` object using the `Community.fromMap` method.
  // The `fromMap` method takes a `Map<String, dynamic>` as input and constructs a `Community` object.

  // The method returns a stream that emits a list of `Community` objects whenever there are updates to the collection.

  // This method allows searching for communities based on the name field in the Firestore database and converts the matching documents to `Community` objects.
  // Usage: `communityRepository.searchCommunity('searchQuery');`

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  // The `addMods` method in the `CommunityRepository` class.
  // It takes two parameters: `communityName` of type `String` representing the name of the community, and `uids` of type `List<String>` representing the IDs of the moderators.
  // It returns a `FutureEither<void>` which represents the success or failure of the operation.

  // The method updates the document of the specified community by calling `_communities.doc(communityName).update()` with the field and value to be updated.
  // It sets the `mods` field of the document to the provided list of moderator IDs.

  // If any Firebase-related exceptions occur, it throws the corresponding error message.
  // If any other exceptions occur, it returns a `left` value (Failure) with the error message.

  // This method adds moderators to a community by updating the `mods` field in the Firestore database and handles success and error scenarios.
  // Usage: `communityRepository.addMods('communityName', ['moderator1', 'moderator2']);`

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts.where('communityName', isEqualTo: name).orderBy('createdAt', descending: true).snapshots().map(
          (event) => event.docs
          .map(
            (e) => Post.fromMap(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
  // Inside the map callback function, it maps over the event.docs and converts each document data to a Post object using the Post.fromMap method.
  // The fromMap method takes a Map<String, dynamic> as input and constructs a Post object.

  // The method returns a stream that emits a list of Post objects whenever there are updates to the collection.

  // This method retrieves and listens to posts associated with a specific community from the Firestore database and converts them to Post objects.
  // The posts are ordered by their creation time in descending order.
  // Usage: communityRepository.getCommunityPosts('communityName');

  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communitiesCollection);
}