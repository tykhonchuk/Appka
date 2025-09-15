import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "config/pages_route.dart";
import "config/theme_dark.dart";
import "config/theme_light.dart";
import "pages/login_page.dart";

void main() {
  final routeBuilders = {
    PagesRoute.loginPage.path: (context) => const LoginPage(),
  };
  final goRoute = GoRouter(
    routes:
      PagesRoute.values.map((route){
        return GoRoute(path: route.path, name: route.name); //dodac to jak beda gotowe cubity  builder: routeBuilders[route]!
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
