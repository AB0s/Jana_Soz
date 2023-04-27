import 'package:flutter/material.dart';
import 'package:jana_soz/features/auth/screens/login_screen.dart';
import 'package:jana_soz/features/community/screens/community_screen.dart';
import 'package:jana_soz/features/community/screens/create_community_screen.dart';
import 'package:jana_soz/features/home/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) => const MaterialPage(child: CreateCommunityScreen()),
    '/r/:name': (route) => MaterialPage(
      child: CommunityScreen(
        name: route.pathParameters['name']!,
      ),
    ),
    '/mod-tools/:name': (routeData) => MaterialPage(
      child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      ),
    ),
    '/edit-community/:name': (routeData) => MaterialPage(
      child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      ),
    ),
    '/add-mods/:name': (routeData) => MaterialPage(
      child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      ),
    ),
    '/u/:uid': (routeData) => MaterialPage(
      child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      ),
    ),
    '/edit-profile/:uid': (routeData) => MaterialPage(
      child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      ),
    ),
    '/add-post/:type': (routeData) => MaterialPage(
      child: AddPostTypeScreen(
        type: routeData.pathParameters['type']!,
      ),
    ),
    '/post/:postId/comments': (route) => MaterialPage(
      child: CommentsScreen(
        postId: route.pathParameters['postId']!,
      ),
    ),
    '/add-post': (routeData) => const MaterialPage(
      child: AddPostScreen(),
    ),
  },
);