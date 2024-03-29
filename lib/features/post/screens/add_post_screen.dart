import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/features/home/delegates/search_community_delegate.dart';
import 'package:jana_soz/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  // Method to navigate to a specific post type screen
  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    
    // Define dimensions based on screen type
    double cardHeight = kIsWeb ? 360 : 120;
    double cardWidth = kIsWeb ? 360 : screenWidth;
    double iconSize = kIsWeb ? 120 : 60;

    // Get the current theme
    final currentTheme = ref.watch(themeNotifierProvider);
    
    // Method to display the app drawer
    void displayDrawer(BuildContext context) {
      Scaffold.of(context).openDrawer();
    }

    // Method to display the end drawer
    void displayEndDrawer(BuildContext context) {
      Scaffold.of(context).openEndDrawer();
    }

    // Get the user information from the provider
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.020),
          GestureDetector(
            onTap: () => navigateToType(context, 'image'),
            child: SizedBox(
              height: cardHeight,
              width: cardWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currentTheme.backgroundColor,
                elevation: 16,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: screenWidth * 0.15,
                        ),
                        const Text(
                          "Suretpen qosu",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          GestureDetector(
            onTap: () => navigateToType(context, 'text'),
            child: SizedBox(
              height: cardHeight,
              width: cardWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currentTheme.backgroundColor,
                elevation: 16,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          Icons.font_download_outlined,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: screenWidth * 0.15,
                        ),
                        const Text(
                          "Sozder gana",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          GestureDetector(
            onTap: () => navigateToType(context, 'link'),
            child: SizedBox(
              height: cardHeight,
              width: cardWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: currentTheme.backgroundColor,
                elevation: 16,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_outlined,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: screenWidth * 0.15,
                        ),
                        const Text(
                          "Syltemeny gana",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
