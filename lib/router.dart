import 'package:flutter/material.dart';
import 'package:jana_soz/features/auth/screens/login_screen.dart';
import 'package:jana_soz/features/community/screens/create_community_screen.dart';
import 'package:jana_soz/features/home/screeens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute=RouteMap(routes: {
  '/':(_)=>const MaterialPage(child: login_screen())
});
final loggedInRoute=RouteMap(routes: {
  '/':(_)=>const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunityScreen()),
});