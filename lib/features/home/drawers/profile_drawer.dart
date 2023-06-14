import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/generated/locale_keys.g.dart';
import 'package:jana_soz/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  // logOut() method triggers the logout functionality when the logout button is tapped.
  // It uses the authControllerProvider to access the auth controller and call the logout method.
  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  // navigateToUserProfile() method navigates to the user profile page when tapped.
  // It uses the Routemaster package to push the corresponding route.
  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  // toggleTheme() method toggles the app theme between light and dark when the switch is changed.
  // It uses the themeNotifierProvider to access the theme notifier and call the toggleTheme method.
  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    // The drawer widget displays the user's profile information, options, and settings.
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            const SizedBox(height: 10),
            Text(
              '${user.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              title: Text(LocaleKeys.Paraqsha.tr()), // User profile option
              leading: const Icon(Icons.person),
              onTap: () => navigateToUserProfile(context, user.uid),
            ),
            ListTile(
              title: Text(LocaleKeys.Shygu.tr()), // Logout option
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              onTap: () => logOut(ref),
            ),
            ListTile(
              title: Text('kz'), // Language option
              leading: const Icon(Icons.language),
              onTap: () {
                context.setLocale(Locale('ru'));
              },
            ),
            ListTile(
              title: Text('ru'), // Language option
              leading: const Icon(Icons.language),
              onTap: () {
                context.setLocale(Locale('de'));
              },
            ),
            ListTile(
              title: Text('eng'), // Language option
              leading: const Icon(Icons.language),
              onTap: () {
                context.setLocale(Locale('en'));
              },
            ),
            Switch.adaptive(
              value: ref.watch(themeNotifierProvider.notifier).mode ==
                  ThemeMode.dark, // Dark mode switch
              onChanged: (val) => toggleTheme(ref),
            ),
          ],
        ),
      ),
    );
  }
}
