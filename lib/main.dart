import "package:appka/cubit/document_cubit.dart";
import "package:appka/cubit/family_cubit.dart";
import "package:appka/cubit/firebase_storage_cubit.dart";
import "package:appka/cubit/ocr_cubit.dart";
import "package:appka/pages/account_created_page.dart";
import "package:appka/pages/add_document_page.dart";
import "package:appka/pages/add_family_member.dart";
import "package:appka/pages/camera_page.dart";
import "package:appka/pages/change_password_page.dart";
import "package:appka/pages/delete_account_page.dart";
import "package:appka/pages/document_details_page.dart";
import "package:appka/pages/edit_document_page.dart";
import "package:appka/pages/edit_profile_page.dart";
import "package:appka/pages/family_member_details_page.dart";
import "package:appka/pages/home_page.dart";
import "package:appka/pages/preview_pdf_page.dart";
import "package:appka/pages/preview_photo_page.dart";
import "package:appka/pages/profile_page.dart";
import "package:appka/pages/signup_page.dart";
import "package:appka/pages/welcome_page.dart";
import "package:appka/config/pages_route.dart";
import "package:appka/config/theme_dark.dart";
import "package:appka/config/theme_light.dart";
import "package:appka/pages/login_page.dart";
import "package:appka/cubit/profile_cubit.dart";
import "package:camera/camera.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:firebase_core/firebase_core.dart";
import "firebase_options.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔥 Próba inicjalizacji z firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('Firebase już zainicjalizowany, używam istniejącej instancji.');
    } else {
      rethrow; // inny błąd – nie ignorujemy
    }
  }
  final app = Firebase.app();
  print('🔥 Firebase app: ${app.name}');
  print('🔥 projectId: ${app.options.projectId}');
  print('🔥 storageBucket z options: ${app.options.storageBucket}');
  await FirebaseAuth.instance.signInAnonymously();


  final routeBuilders = {
    PagesRoute.welcomePage.path: (context, state) => const WelcomePage(),
    PagesRoute.loginPage.path: (context, state) => const LoginPage(),
    PagesRoute.signupPage.path: (context, state) => const SignupPage(),
    PagesRoute.homePage.path: (context, state) {
      final int index = state.extra is int ? state.extra as int : 0;
      return HomePage(initialIndex: index);
    },
    PagesRoute.accountCreatedPage.path: (context, state) => const AccountCreatedPage(),
    PagesRoute.profilePage.path: (context, state) => const ProfilePage(),
    PagesRoute.changePasswordPage.path: (context, state) => const ChangePasswordPage(),
    PagesRoute.deletePage.path: (context, state) => const DeleteAccountPage(),
    PagesRoute.addDocumentPage.path: (context, state) => const AddDocumentPage(),
    PagesRoute.editDocumentPage.path: (context, state) {
      final data = state.extra as Map<String, dynamic>?;
      return EditDocumentPage(initialData: data);
    },
    PagesRoute.documentDetailsPage.path: (context, state){
      final data = state.extra as Map<String, dynamic>;
      return DocumentDetailsPage(document: data);
    },
    PagesRoute.cameraPage.path: (context, state){
      final camera = state.extra as CameraDescription;
      return CameraScreen(
        camera: camera,
        onImageTaken: (path) {},
      );
    },
    PagesRoute.previewPhotoPage.path: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return PreviewPhotoPage(
        imagePath: args['imagePath'],
        onAccept: args['onAccept'],
        onRetake: args['onRetake'],
        onBack: args['onBack'],
      );
    },
    PagesRoute.previewPDFPage.path: (context, state){
      final args = state.extra as Map<String, dynamic>;
      return PreviewPDFPage(
        filePath: args['filePath'],
        onBack: args['onBack'],
        onPickAgain: args['onPickAgain'],
        onApprove: args['onApprove'],
      );
    } ,
    PagesRoute.editProfilePage.path: (context, state) => const EditProfilePage(),
    PagesRoute.addFamilyMemberPage.path: (context, state) => const AddFamilyMemberPage(),

    PagesRoute.familyMemberPage.path: (context, state) {
      final member = state.extra as Map<String, dynamic>?;
      if (member == null) {
        return const Scaffold(
          body: Center(child: Text("Brak danych członka rodziny")),
        );
      }
      return MemberDetailPage(member: member);
    },
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
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => OcrCubit()),
        BlocProvider(create: (_) => DocumentCubit()),
        BlocProvider(create: (_) => FirebaseStorageCubit()),
        BlocProvider(create: (_) => FamilyCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: goRoute,
        theme: themeLight,
        darkTheme: themeDark,
      ),
    ),
  );
}
