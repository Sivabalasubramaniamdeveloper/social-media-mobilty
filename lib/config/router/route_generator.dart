import 'package:flutter/material.dart';
import 'package:flutter_automation/config/router/route_names.dart';
import 'package:flutter_automation/features/info/presentation/pages/info_screen.dart';
import 'package:flutter_automation/features/info/presentation/pages/screen1.dart';
import 'package:flutter_automation/features/info/presentation/pages/screen2.dart';
import 'package:flutter_automation/features/info/presentation/pages/screen3.dart';
import 'package:flutter_automation/features/products/presentation/pages/products_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/presentation/pages/single_product.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return _buildPageRoute(InfoScreen(), settings);
      case RouteNames.screen1:
        return _buildPageRoute(Screen1(), settings);
      case RouteNames.screen2:
        return _buildPageRoute(Screen2(), settings);
      case RouteNames.screen3:
        return _buildPageRoute(Screen3(), settings);
      case RouteNames.products:
        return _buildPageRoute(ProductsPage(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: '/',
        builder: (context, state) => InfoScreen(),
      ),
      GoRoute(
        name: RouteNames.products,
        path: '/products',
        builder: (context, state) => ProductsPage(),
        routes: <RouteBase>[
          GoRoute(
            name: "sss",
            path: 'single-product/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SingleProduct(productId: id);
            },
          ),
        ],
      ),
      GoRoute(
        name: RouteNames.screen1,
        path: '/screen1',
        builder: (context, state) => Screen1(),
      ),
      GoRoute(
        name: RouteNames.screen2,
        path: '/screen2',
        builder: (context, state) => Screen2(),
      ),
      GoRoute(
        name: RouteNames.screen3,
        path: '/screen3',
        builder: (context, state) => Screen3(),
      ),
      // GoRoute(
      //   path: '/profile/:id',  // Dynamic path
      //   builder: (context, state) {
      //     final id = state.pathParameters['id']!;
      //     return ProfilePage(userId: id);
      //   },
      // ),
    ],
    // redirect: (context, state) {
    //   // Example: simple auth guard
    //   // CustomAppLogger.appLogger("state.path", state.path!);
    // },
  );

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // From left
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
