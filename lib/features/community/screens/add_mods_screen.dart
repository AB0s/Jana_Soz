import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/error_text.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/features/auth/controller/auth_controller.dart';
import 'package:jana_soz/features/community/controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref.read(communityControllerProvider.notifier).addMods(
      widget.name,
      uids.toList(),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => ListView.builder(
          itemCount: community.members.length,
          itemBuilder: (BuildContext context, int index) {
            uids=community.mods.toSet();
            final member = community.members[index];
            return ref.watch(getUserDataProvider(member)).when(
              data: (user) {
                print(uids);
                return CheckboxListTile(
                  value: uids.contains(user.uid),
                  onChanged: (val) {
                    if (val!) {
                      community.mods.add(user.uid);
                      setState(() {});
                    } else {
                      community.mods.remove(user.uid);
                      setState(() {});
                    }
                  },
                  title: Text(user.name),
                );
              },
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            );
          },
        ),
        error: (error, stackTrace) => ErrorText(
          error: error.toString(),
        ),
        loading: () => const Loader(),
      ),
    );
  }
}