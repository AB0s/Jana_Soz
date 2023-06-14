// Import necessary packages and files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jana_soz/core/constants/firebase_constants.dart';
import 'package:jana_soz/core/failure.dart';
import 'package:jana_soz/core/providers/firebase_providers.dart';
import 'package:jana_soz/core/type_defs.dart';
import 'package:jana_soz/models/comment_model.dart';
import 'package:jana_soz/models/community_model.dart';
import 'package:jana_soz/models/post_model.dart';

// Provider for the PostRepository
final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

// Repository class for handling posts, comments, and interactions
class PostRepository {
  final FirebaseFirestore _firestore;

  // Constructor to initialize the Firestore instance
  PostRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  // Get references to the Firestore collections
  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments => _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  // Add a post to Firestore
  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Fetch user posts based on the specified communities
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName', whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
          .map(
            (e) => Post.fromMap(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  // Fetch guest posts (latest 10)
  Stream<List<Post>> fetchGuestPosts() {
    return _posts.orderBy('createdAt', descending: true).limit(10).snapshots().map(
          (event) => event.docs
          .map(
            (e) => Post.fromMap(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  // Delete a post from Firestore
  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Upvote a post and handle vote count updates
  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Downvote a post and handle vote count updates
  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Get a post by its ID
  Stream<Post> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  // Add a comment to a post and update the comment count
  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Get comments of a post
  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments.where('postId', isEqualTo: postId).orderBy('createdAt', descending: true).snapshots().map(
          (event) => event.docs
          .map(
            (e) => Comment.fromMap(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  // Award a post and update award lists
  FutureVoid awardPost(Post post, String award, String senderId) async {
    try {
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
