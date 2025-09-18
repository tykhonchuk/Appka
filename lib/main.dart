import "package:appka/pages/home_page.dart";
import "package:appka/pages/signup_page.dart";
import "package:appka/pages/welcome_page.dart";
import "package:appka/config/pages_route.dart";
import "package:appka/config/theme_dark.dart";
import "package:appka/config/theme_light.dart";
import "package:appka/pages/login_page.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

void main() {
  final routeBuilders = {
    PagesRoute.welcomePage.path: (context, state) => const WelcomePage(),
    PagesRoute.loginPage.path: (context, state) => const LoginPage(),
    PagesRoute.signupPage.path: (context, state) => const SignupPage(),
    PagesRoute.homePage.path: (context, state) => const HomePage(),
  };
  final goRoute = GoRouter(
    initialLocation: PagesRoute.welcomePage.path,
    routes:
      PagesRoute.values.map((route){
        return GoRoute(path: route.path, name: route.name, builder: routeBuilders[route.path]!);
      }).toList(),
  );
  runApp(
    MaterialApp.router(
      routerConfig: goRoute,
      theme: themeLight,
      darkTheme: themeDark,
    ),
  );
}
