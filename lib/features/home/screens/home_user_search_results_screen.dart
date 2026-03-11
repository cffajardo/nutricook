import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/routing/app_routes.dart';

class HomeUserSearchResultsScreen extends ConsumerWidget {
  const HomeUserSearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmedQuery = query.trim();
    final currentUserId = ref.watch(currentUserIdProvider);

    if (trimmedQuery.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Search',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
        body: const Center(
          child: Text(
            'Enter a search term from Home to find users and recipes.',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final usersAsync = ref.watch(discoverUsersProvider(trimmedQuery));
    final recipesAsync = ref.watch(
      filteredRecipesProvider(RecipeFilterInput(query: trimmedQuery)),
    );

    final userResults = usersAsync.asData?.value;
    final recipeResults = recipesAsync.asData?.value;
    final hasNoResults =
        userResults != null &&
        recipeResults != null &&
        userResults.isEmpty &&
        recipeResults.isEmpty;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Results for "$trimmedQuery"',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _SearchResultsTabBar(),
            ),
          ),
        ),
        body: hasNoResults
            ? const Center(
                child: Text(
                  'No users or recipes found.',
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _SectionTitle(
                        title: 'Users',
                        subtitle: 'People matching "$trimmedQuery"',
                      ),
                      const SizedBox(height: 10),
                      _buildUsersSection(
                        context: context,
                        usersAsync: usersAsync,
                        currentUserId: currentUserId,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        title: 'Recipes',
                        subtitle: 'Recipes matching "$trimmedQuery"',
                      ),
                      const SizedBox(height: 10),
                      _buildRecipesSection(recipesAsync),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _SectionTitle(
                        title: 'Users',
                        subtitle: 'People matching "$trimmedQuery"',
                      ),
                      const SizedBox(height: 10),
                      _buildUsersSection(
                        context: context,
                        usersAsync: usersAsync,
                        currentUserId: currentUserId,
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _SectionTitle(
                        title: 'Recipes',
                        subtitle: 'Recipes matching "$trimmedQuery"',
                      ),
                      const SizedBox(height: 10),
                      _buildRecipesSection(recipesAsync),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUsersSection({
    required BuildContext context,
    required AsyncValue<List<Map<String, dynamic>>> usersAsync,
    required String? currentUserId,
  }) {
    return usersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _SectionMessage('Failed to search users: $error'),
      data: (users) {
        if (users.isEmpty) {
          return const _SectionMessage('No users found.');
        }

        return Column(
          children: [
            for (var i = 0; i < users.length; i++) ...[
              _buildUserResultTile(
                context: context,
                user: users[i],
                currentUserId: currentUserId,
              ),
              if (i != users.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRecipesSection(AsyncValue<List<Recipe>> recipesAsync) {
    return recipesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _SectionMessage('Failed to search recipes: $error'),
      data: (recipes) {
        if (recipes.isEmpty) {
          return const _SectionMessage('No recipes found.');
        }

        final limitedRecipes = recipes.take(8).toList(growable: false);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: limitedRecipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            return RecipeCard(recipe: limitedRecipes[index]);
          },
        );
      },
    );
  }

  Widget _buildUserResultTile({
    required BuildContext context,
    required Map<String, dynamic> user,
    required String? currentUserId,
  }) {
    final userId = (user['id'] ?? '').toString();
    final username = (user['username'] ?? 'Unknown').toString();
    final email = (user['email'] ?? '').toString();
    final profileImageUrl =
        (user['mediaId'] ?? user['profilePictureUrl'])?.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: userId.isEmpty
          ? null
          : () {
              if (userId == currentUserId) {
                context.goNamed(AppRoutes.profileName);
                return;
              }

              context.pushNamed(
                AppRoutes.profileUserName,
                pathParameters: {'userId': userId},
              );
            },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.15),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.cardRose,
              backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.rosePink,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@$username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsTabBar extends StatelessWidget {
  const _SearchResultsTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.18),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.rosePink,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Users'),
          Tab(text: 'Recipes'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.rosePink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
