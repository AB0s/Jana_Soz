import 'package:flutter/material.dart';
import 'package:jana_soz/features/auth/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute=RouteMap(routes: {
  '/':(_)=>const MaterialPage(child: login_screen())
});