import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/auth/screens/login_screen.dart';
import 'package:nutricook/features/auth/screens/register_screen.dart';
import 'package:nutricook/features/auth/screens/verify_email_screen.dart';
import 'package:nutricook/features/recipe/screens/recipe_main.dart';
import 'package:nutricook/features/recipe/screens/recipe_category.dart'; 
import 'package:nutricook/features/recipe/screens/recipe_create.dart';
import 'package:nutricook/features/planner/screens/planner_main.dart';
import 'package:nutricook/screens/home_screen.dart';
import 'package:nutricook/screens/splash_screen.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:nutricook/features/recipe/screens/recipe_subcategory_list.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == AppRoutes.loginPath || path == AppRoutes.registerPath;
      final isVerifyEmailRoute = path == AppRoutes.verifyEmailPath;
      final isSplashRoute = path == AppRoutes.splashPath;

      if (isSplashRoute) return null;

      return userAsync.when(
        loading: () => null,
        error: (_, _) => AppRoutes.loginPath,
        data: (user) {
          if (user == null) return isAuthRoute ? null : AppRoutes.loginPath;
          
          final needsVerif = user.email != null && user.email!.isNotEmpty && !user.emailVerified;
          if (needsVerif) return isVerifyEmailRoute ? null : AppRoutes.verifyEmailPath;

          if (isAuthRoute || isVerifyEmailRoute) return AppRoutes.homePath;
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final hideBottomNav = state.uri.path == AppRoutes.recipeCreatePath;

          return Scaffold(
            extendBody: true, 
            body: navigationShell,
            bottomNavigationBar: hideBottomNav ? null : const CustomBottomNavBar(),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.recipesPath,
                name: AppRoutes.recipesName,
                builder: (context, state) => const RecipeMainScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: AppRoutes.recipeCreateName,
                    builder: (context, state) => const CreateRecipeScreen(),
                  ),
                  GoRoute(
                    path: ':category', 
                    name: 'subCategory',
                    builder: (context, state) {
                      final category = state.pathParameters['category'] ?? 'Cuisine';
                      return RecipeSubCategoryScreen(category: category);
                    },
                    routes: [
                          GoRoute(
                            path: ':subCategoryName', 
                            name: 'recipeList',
                            builder: (context, state) {
                              final category = state.pathParameters['category'] ?? '';
                              final subName = state.pathParameters['subCategoryName'] ?? '';
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
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});