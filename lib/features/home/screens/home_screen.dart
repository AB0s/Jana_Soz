import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/constants/constants.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/features/home/delegates/search_community_delegate.dart';
import 'package:jana_soz/features/home/drawers/community_list_drawer.dart';
import 'package:jana_soz/features/home/drawers/profile_drawer.dart';
import 'package:jana_soz/generated/locale_keys.g.dart';
import 'package:jana_soz/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  // displayDrawer() method opens the main drawer when the menu button is tapped.
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  // displayEndDrawer() method opens the profile drawer when the user avatar button is tapped.
  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  // onPageChanged() method updates the current page index when the bottom navigation bar item is tapped.
  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.NegizgiBet.tr()),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Routemaster.of(context).push('/add-post');
            },
            icon: const Icon(Icons.add),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          }),
        ],
      ),
      body: Constants.tabWidgets[_page], // The body displays the content of the selected tab.
      drawer: const CommunityListDrawer(), // The main drawer widget.
      endDrawer: isGuest ? null : const ProfileDrawer(), // The profile drawer widget (only shown when the user is authenticated).
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.backgroundColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: '',
                ),
              ],
              onTap: onPageChanged,
              currentIndex: _page,
            ),
    );
  }
}
