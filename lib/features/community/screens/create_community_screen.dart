import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/features/community/controller/community_controller.dart';
import 'package:jana_soz/generated/locale_keys.g.dart';
import 'package:jana_soz/responsive/responsive.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
      communityNameController.text.trim(),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title:  Text(LocaleKeys.QawQury.tr()),
      ),
      body: isLoading
          ? const Loader()
          : Responsive(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
               Align(
                alignment: Alignment.topLeft,
                child: Text(LocaleKeys.Qawat.tr()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: communityNameController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.Qawat.tr(),
                  filled: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLength: 21,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: createCommunity,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                child:  Text(
                  LocaleKeys.QawQury.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}