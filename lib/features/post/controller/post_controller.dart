import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/enums/enums.dart';
import 'package:jana_soz/core/providers/storage_repository_provider.dart';
import 'package:jana_soz/core/utils.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/features/post/repository/post_repository.dart';
import 'package:jana_soz/features/user_profile/controller/user_profile_controller.dart';
import 'package:jana_soz/models/comment_model.dart';
import 'package:jana_soz/models/community_model.dart';
import 'package:jana_soz/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

// postControllerProvider is a StateNotifierProvider that provides an instance of PostController.
final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

// userPostsProvider is a StreamProvider that provides a stream of user posts based on a list of communities.
final userPostsProvider = StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

// guestPostsProvider is a StreamProvider that provides a stream of guest posts.
final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

// getPostByIdProvider is a StreamProvider that provides a stream of a post based on its ID.
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

// getPostCommentsProvider is a StreamProvider that provides a stream of comments for a specific post.
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  // shareTextPost() method adds a text post.
  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    // Set state to true to indicate that the post is being added.
    state = true;

    // Generate a unique ID for the post.
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    // Create a new Post instance with the provided data.
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    // Add the post to the post repository.
    final res = await _postRepository.addPost(post);

    // Update user karma and reset the state.
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.textPost);
    state = false;

    // Show a snackbar with the result of the operation.
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  // shareLinkPost() method adds a link post.
  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    // Set state to true to indicate that the post is being added.
    state = true;

    // Generate a unique ID for the post.
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    // Create a new Post instance with the provided data.
    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    // Add the post to the post repository.
    final res = await _postRepository.addPost(post);

    // Update user karma and reset the state.
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.linkPost);
    state = false;

    // Show a snackbar with the result of the operation.
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  // shareImagePost() method adds an image post.
  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required Uint8List? webFile,
  }) async {
    // Set state to true to indicate that the post is being added.
    state = true;

    // Generate a unique ID for the post.
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    // Store the image file in the storage repository.
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
      webFile: webFile,
    );

    // Check the result of storing the image file.
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      // Create a new Post instance with the provided data.
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      // Add the post to the post repository.
      final res = await _postRepository.addPost(post);

      // Update user karma and reset the state.
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.imagePost);
      state = false;

      // Show a snackbar with the result of the operation.
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  // fetchUserPosts() method retrieves the user's posts from the post repository.
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  // fetchGuestPosts() method retrieves the guest posts from the post repository.
  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  // deletePost() method deletes a post from the post repository.
  void deletePost(Post post, BuildContext context) async {
    // Delete the post from the post repository.
    final res = await _postRepository.deletePost(post);

    // Update user karma and show a snackbar with the result of the operation.
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.deletePost);
    res.fold((l) => null, (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }

  // upvote() method upvotes a post.
  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;

    // Upvote the post in the post repository.
    _postRepository.upvote(post, uid);
  }

  // downvote() method downvotes a post.
  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;

    // Downvote the post in the post repository.
    _postRepository.downvote(post, uid);
  }

  // getPostById() method retrieves a post by its ID from the post repository.
  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  // addComment() method adds a comment to a post.
  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;

    // Generate a unique ID for the comment.
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name,
      profilePic: user.profilePic,
    );

    // Add the comment to the post repository.
    final res = await _postRepository.addComment(comment);

    // Update user karma and show a snackbar with the result of the operation.
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  // awardPost() method awards a post.
  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    // Award the post in the post repository.
    final res = await _postRepository.awardPost(post, award, user.uid);

    // Show a snackbar with the result of the operation.
    res.fold((l) => showSnackBar(context, l.message), (r) {
      // Update user karma and remove the awarded from the user's awards list.
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.award);
      _ref.read(userProfileControllerProvider.notifier).removeAward(award);
    });
  }

  // fetchPostComments() method retrieves comments for a specific post from the post repository.
  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.fetchPostComments(postId);
  }
}
