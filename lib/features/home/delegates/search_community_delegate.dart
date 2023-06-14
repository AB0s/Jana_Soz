import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jana_soz/core/common/error_text.dart';
import 'package:jana_soz/core/common/loader.dart';
import 'package:jana_soz/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);

  // buildActions() method builds the actions for the search delegate.
  // In this case, it adds a clear button to clear the search query.
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  // buildLeading() method builds the leading widget of the search delegate.
  // In this case, it returns null, indicating there is no leading widget.
  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  // buildResults() method builds the widget that displays the search results.
  // In this case, it returns an empty SizedBox, indicating no results to display.
  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  // buildSuggestions() method builds the widget that displays search suggestions.
  // It uses the searchCommunityProvider to fetch and display communities based on the query.
  // The result can be in three states: data, error, or loading.
  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
      data: (communites) => ListView.builder(
        itemCount: communites.length,
        itemBuilder: (BuildContext context, int index) {
          final community = communites[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(community.avatar),
            ),
            title: Text('r/${community.name}'),
            onTap: () => navigateToCommunity(context, community.name),
          );
        },
      ),
      error: (error, stackTrace) => ErrorText(
        error: error.toString(),
      ),
      loading: () => const Loader(),
    );
  }

  // navigateToCommunity() method navigates to the selected community when tapped.
  // It uses the Routemaster package to push the corresponding route.
  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }
}
