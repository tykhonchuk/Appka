import "package:appka/pages/account_created_page.dart";
import "package:appka/pages/add_document_page.dart";
import "package:appka/pages/change_password_page.dart";
import "package:appka/pages/delete_account_page.dart";
import "package:appka/pages/home_page.dart";
import "package:appka/pages/profile_page.dart";
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
    PagesRoute.accountCreatedPage.path: (context, state) => const AccountCreatedPage(),
    PagesRoute.profilePage.path: (context, state) => const ProfilePage(),
    PagesRoute.changePasswordPage.path: (context, state) => const ChangePasswordPage(),
    PagesRoute.deletePage.path: (context, state) => const DeleteAccountPage(),
    PagesRoute.addDocumentPage.path: (context, state) => const AddDocumentPage(),

  };
  final goRoute = GoRouter(
    initialLocation: PagesRoute.welcomePage.path,
    routes:
      PagesRoute.values.map((route){
        final builder = routeBuilders[route.path];
        if (builder == null) {
          throw Exception("Brak implementacji widoku dla ${route.name} ${route.path}");
        }
        return GoRoute(
          path: route.path,
          name: route.name,
          builder: builder
        );
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
