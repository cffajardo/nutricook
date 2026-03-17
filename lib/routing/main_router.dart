import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/auth/screens/login_screen.dart';
import 'package:nutricook/features/auth/screens/register_screen.dart';
import 'package:nutricook/features/auth/screens/verify_email_screen.dart';
import 'package:nutricook/features/admin/screens/admin_panel_page.dart';
import 'package:nutricook/features/admin/screens/banned_screen.dart';
import 'package:nutricook/features/admin/screens/edit_ingredient_screen.dart';
import 'package:nutricook/features/recipe/screens/recipe_main.dart';
import 'package:nutricook/features/recipe/screens/recipe_subcategory_list.dart';
import 'package:nutricook/features/recipe/screens/recipe_create.dart';
import 'package:nutricook/features/recipe/screens/recipe_category.dart';
import 'package:nutricook/features/recipe/screens/recipe_main_details.dart';
import 'package:nutricook/features/planner/screens/planner_main.dart';
import 'package:nutricook/features/planner/screens/planner_history_screen.dart';
import 'package:nutricook/features/profile/screens/edit_profile_page.dart';
import 'package:nutricook/features/profile/screens/followers_following_page.dart';
import 'package:nutricook/features/profile/screens/profile_page.dart';
import 'package:nutricook/features/settings/screens/settings_page.dart';
import 'package:nutricook/features/home/screens/home_user_search_results_screen.dart';
import 'package:nutricook/features/notifications/screens/notifications_page.dart';
import 'package:nutricook/features/notifications/screens/notification_test_page.dart';
import 'package:nutricook/features/library/screens/library_main.dart';
import 'package:nutricook/features/library/screens/library_subcategory.dart';
import 'package:nutricook/features/library/screens/library_main_item.dart';
import 'package:nutricook/features/archive/screens/archive_page.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/screens/home_screen.dart';
import 'package:nutricook/screens/splash_screen.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/routing/navigation_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final coreUserDataAsync = ref.watch(coreUserDataProvider);

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute =
          path == AppRoutes.loginPath || path == AppRoutes.registerPath;
      final isVerifyEmailRoute = path == AppRoutes.verifyEmailPath;
      final isSplashRoute = path == AppRoutes.splashPath;
      final isAdminRoute = path.startsWith(AppRoutes.adminPath);
      final isBannedRoute = path == AppRoutes.bannedPath;
      
      // Check if this is a deep link route (starts with /recipe/)
      final isDeepLinkRoute = path.startsWith('/recipe/');

      if (isSplashRoute) return null;

      return userAsync.when(
        loading: () => null,
        error: (_, _) => AppRoutes.loginPath,
        data: (user) {
          if (user == null) {
            // Allow deep link routes for unauthenticated users
            if (isDeepLinkRoute) return null;
            return isAuthRoute ? null : AppRoutes.loginPath;
          }

          // coreUserDataProvider only includes routing-critical fields
          final userData = coreUserDataAsync.asData?.value;
          // If userData is null or empty, treat as not banned/not admin
          final isBanned = userData != null && userData['isBanned'] == true;
          if (isBanned) {
            return isBannedRoute ? null : AppRoutes.bannedPath;
          }

          if (!isBanned && isBannedRoute) {
            return AppRoutes.homePath;
          }

          final role = (userData?['role'] ?? '').toString().toLowerCase();
          final isAdmin = role == 'admin' || userData?['isAdmin'] == true;
          if (isAdminRoute && !isAdmin) {
            return AppRoutes.homePath;
          }

          final needsVerif =
              user.email != null &&
              user.email!.isNotEmpty &&
              !user.emailVerified;
          if (needsVerif) {
            return isVerifyEmailRoute ? null : AppRoutes.verifyEmailPath;
          }

          if (isAuthRoute || isVerifyEmailRoute) return AppRoutes.homePath;

          if (isDeepLinkRoute) return null;
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/recipe/:recipeId',
        name: 'recipe_deeplink',
        builder: (context, state) {
          final recipeId = state.pathParameters['recipeId'] ?? '';
          final recipeService = RecipeService();

          return StreamBuilder<Recipe?>(
            stream: recipeService.getRecipeById(recipeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Recipe not found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final recipe = snapshot.data!;
              return RecipeDetailsScreen(recipe: recipe);
            },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmailPath,
        name: AppRoutes.verifyEmailName,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.bannedPath,
        name: AppRoutes.bannedName,
        builder: (context, state) => const BannedScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPath,
        name: AppRoutes.adminName,
        builder: (context, state) => const AdminPanelPage(),
        routes: [
          GoRoute(
            path: 'ingredient/:ingredientId',
            name: AppRoutes.adminEditIngredientName,
            builder: (context, state) {
              final ingredientId = state.pathParameters['ingredientId'] ?? '';
              return EditIngredientScreen(ingredientId: ingredientId);
            },
          ),
        ],
      ),

      // Development only: Notification testing
      if (const bool.fromEnvironment('dart.vm.product') == false)
        GoRoute(
          path: AppRoutes.notificationTestPath,
          name: AppRoutes.notificationTestName,
          builder: (context, state) => const NotificationTestPage(),
        ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final path = state.uri.path;
          final hideBottomNav =
              path == AppRoutes.recipeCreatePath ||
              path == AppRoutes.recipeDetailsPath ||
              path == '${AppRoutes.profilePath}/${AppRoutes.settingsPath}' ||
              path == '${AppRoutes.profilePath}/${AppRoutes.editProfilePath}' ||
              path ==
                  '${AppRoutes.profilePath}/${AppRoutes.profileConnectionsPath}';

          // Sync the active tab index with our provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(activeTabProvider) != navigationShell.currentIndex) {
              ref.read(activeTabProvider.notifier).state =
                  navigationShell.currentIndex;
            }
          });

          return Scaffold(
            backgroundColor: Colors.white,
            body: navigationShell,
            bottomNavigationBar: hideBottomNav
                ? null
                : const CustomBottomNavBar(),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.recipesPath,
                name: AppRoutes.recipesName,
                builder: (context, state) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) context.go(AppRoutes.homePath);
                  },
                  child: const RecipeMainScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: AppRoutes.recipeCreateName,
                    builder: (context, state) => const CreateRecipeScreen(),
                  ),
                  GoRoute(
                    path: 'view',
                    name: AppRoutes.recipeDetailsName,
                    builder: (context, state) {
                      final recipe = state.extra as Recipe;
                      return RecipeDetailsScreen(recipe: recipe);
                    },
                  ),
                  GoRoute(
                    path: ':category',
                    name: 'subCategory',
                    builder: (context, state) {
                      final category =
                          state.pathParameters['category'] ?? 'Cuisine';
                      return RecipeSubCategoryScreen(category: category);
                    },
                    routes: [
                      GoRoute(
                        path: ':subCategoryName',
                        name: 'recipeList',
                        builder: (context, state) {
                          final category =
                              state.pathParameters['category'] ?? '';
                          final subName =
                              state.pathParameters['subCategoryName'] ?? '';
                          return RecipeCategoryListScreen(
                            category: category,
                            subCategoryName: subName,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'user/custom',
                    name: 'userCustomRecipes',
                    builder: (context, state) => const RecipeCategoryListScreen(
                      category: 'My Recipes',
                      subCategoryName: 'Custom',
                    ),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plannerPath,
                name: AppRoutes.plannerName,
                builder: (context, state) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) context.go(AppRoutes.homePath);
                  },
                   child: const PlannerScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'history',
                    name: AppRoutes.plannerHistoryName,
                    builder: (context, state) => const PlannerHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.homeName,
                builder: (context, state) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) return;
                  },
                  child: const HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    name: AppRoutes.notificationsName,
                    builder: (context, state) => const NotificationsPage(),
                  ),
                  GoRoute(
                    path: 'search-users',
                    name: AppRoutes.homeUserSearchName,
                    builder: (context, state) {
                      final query = state.uri.queryParameters['q'] ?? '';
                      return HomeUserSearchResultsScreen(query: query);
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.libraryPath,
                name: AppRoutes.libraryName,
                builder: (context, state) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) context.go(AppRoutes.homePath);
                  },
                  child: const LibraryMainScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':categoryId',
                    name: 'libSubCategory',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['categoryId'] ?? '';
                      return LibrarySubCategoryScreen(categoryId: categoryId);
                    },
                    routes: [
                      GoRoute(
                        path: ':subCategoryId',
                        name: 'libItemDetail',
                        builder: (context, state) {
                          final categoryId =
                              state.pathParameters['categoryId'] ?? '';
                          final subCategoryId =
                              state.pathParameters['subCategoryId'] ?? '';
                          return LibraryItemDetailScreen(
                            categoryId: categoryId,
                            subCategoryId: subCategoryId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profileName,
                builder: (context, state) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) context.go(AppRoutes.homePath);
                  },
                  child: const ProfilePage(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.profileConnectionsPath,
                    name: AppRoutes.profileConnectionsName,
                    builder: (context, state) {
                      final userId = state.uri.queryParameters['userId'] ?? '';
                      final initialTab =
                          int.tryParse(
                            state.uri.queryParameters['tab'] ?? '0',
                          ) ??
                          0;
                      return FollowersFollowingPage(
                        userId: userId,
                        initialTab: initialTab,
                      );
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.editProfilePath,
                    name: AppRoutes.editProfileName,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: AppRoutes.settingsPath,
                    name: AppRoutes.settingsName,
                    builder: (context, state) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.archivePath,
                    name: AppRoutes.archiveName,
                    builder: (context, state) => const ArchivePage(),
                  ),
                  GoRoute(
                    path: ':userId',
                    name: AppRoutes.profileUserName,
                    builder: (context, state) {
                      final userId = state.pathParameters['userId'];
                      return ProfilePage(userId: userId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
