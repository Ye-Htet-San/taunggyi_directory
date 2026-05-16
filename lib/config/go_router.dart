import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/providers.dart';
import 'package:tgi_directory/features/auth/presentation/screens/login_page.dart';
import 'package:tgi_directory/features/auth/presentation/screens/signup_page.dart';
import 'package:tgi_directory/features/auth/presentation/screens/auth_splash_screen.dart';
import 'package:tgi_directory/features/auth/presentation/screens/welcome_splash_screen.dart';
import 'package:tgi_directory/features/categories/presentation/screens/category_detail_page.dart';
import 'package:tgi_directory/features/categories/presentation/screens/category_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/my_reviews_page.dart';
import 'package:tgi_directory/features/reviews/presentation/rate_and_review.dart';
import 'package:tgi_directory/features/favorites/presentation/screens/favorite_page.dart';
import 'package:tgi_directory/features/home/presentation/screens/home_page.dart';
import 'package:tgi_directory/features/home/presentation/widgets/search_places_page.dart';
import 'package:tgi_directory/features/map/presentation/screens/map_page.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';
import 'package:tgi_directory/features/places/presentation/screens/place_detail_page.dart';
import 'package:tgi_directory/features/places/presentation/screens/place_grid_screen.dart';
import 'package:tgi_directory/features/profile/presentation/screens/account_details_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/edit_profile.dart';
import 'package:tgi_directory/features/profile/presentation/screens/profile_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/select_bio_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/select_location_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/settings_page.dart';
import 'package:tgi_directory/features/profile/presentation/screens/short_tag.dart';
import 'package:tgi_directory/features/reviews/presentation/all_reviews_page.dart';
import 'package:tgi_directory/layout/main_scaffold.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authController,
    routes: [
      // Welcome Splash Screen (only first launch)
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeSplashScreen(),
      ),

      // Auth / Loading Splash Screen
      GoRoute(
        path: '/auth-splash',
        builder: (context, state) => const AuthSplashScreen(),
      ),

      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),

      // Place routes
      GoRoute(
        path: '/place-detail',
        builder: (context, state) {
          final place = state.extra as Place;
          return PlaceDetailPage(place: place);
        },
        routes: [
          GoRoute(
            path: '/review/:placeId',
            name: 'review',
            builder: (context, state) {
              final placeId = state.pathParameters['placeId']!;
              return RateAndReview(placeId: placeId);
            },
          ),
          GoRoute(
            path: 'all-reviews',
            name: 'allReviews',
            builder: (context, state) {
              // final placeTitle = extraData['title'] as String;
              return AllReviewsPage();
            },
          ),
        ],
      ),

      GoRoute(
        path: '/place-grid',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Places';
          final places = state.extra as List<Place>;
          return PlaceGridScreen(title: title, places: places);
        },
      ),

      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          final index = getIndexFormLocation(state.uri.path);
          return MainScaffold(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: '/search-places',
                builder: (context, state) {
                  return SearchPlacesPage(); // get the passed data
                },
              ),
            ],
          ),
          GoRoute(
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),

          GoRoute(
            path: '/category/:id',
            builder: (context, state) {
              final categoryId = int.parse(state.pathParameters['id']!);
              return CategoryDetailPage(categoryId: categoryId);
            },
          ),
          GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: '/edit',
                builder: (context, state) => const EditProfilePage(),
                routes: [
                  GoRoute(
                    path: '/select-bio',
                    builder: (context, state) {
                      final bioOptions = state.extra as Map<String, dynamic>;
                      return SelectBioPage(
                        bioOptions: bioOptions['bioOptions'],
                        selectedBios: bioOptions['selectedBios'],
                      );
                    },
                  ),
                  GoRoute(
                    path: '/short-tagline',
                    builder: (context, state) => const ShortTag(),
                  ),
                  GoRoute(
                    path: '/select-location',
                    builder: (context, state) => SelectLocationPage(),
                  ),
                ],
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: '/account',
                    builder: (context, state) => const AccountDetailsPage(),
                  ),
                ],
              ),
              GoRoute(
                path: '/my-reviews',
                builder: (context, state) => const MyReviewsPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isAuthChecked = authController.isAuthChecked;

      //This checks if the user is logged in. It reads from (authControllerProvider)
      final loggedIn =
          authController.isLoggedIn; //Checking whether login or not(true/false)

      final isWelcome =
          state.matchedLocation ==
          '/'; // This checks if the current page being visited is the **splash screen**

      final isAuthSplash = state.matchedLocation == '/auth-splash';

      final isLogin =
          state.matchedLocation ==
          '/login'; // This checks if the current page being visited is the login page.
      final isSignup = state.matchedLocation == '/signup';

      // Wait until auth check is complete
      if (!isAuthChecked && !isWelcome && !isAuthSplash) return '/auth-splash';

      //Allow welcome screen to be shown only once when the app first opens.
      if (isWelcome) {
        return null;
      }

      //If the user is **not logged in**, only allow `/login` route.
      //If they try to access any other page (like `/home`), redirect to `/login`.

      if (!loggedIn && !(isLogin || isSignup || isAuthSplash)) {
        return '/login';
      }

      // the user is already logged in, and they somehow go to the /login route again (e.g., via back button), redirect them to /home.
      if (loggedIn && (isLogin || isSignup || isWelcome)) {
        return '/home';
      }

      print(
        "Redirect running: isLoggedIn = ${authController.isLoggedIn}, location = ${state.matchedLocation}",
      );

      return null;
    },
  );
});

int getIndexFormLocation(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/category')) return 1;
  if (location.startsWith('/map')) return 2;
  if (location.startsWith('/favorites')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}
