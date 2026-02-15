import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/routes/app_pages.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/services/notification_service.dart';
import 'package:epesantren_mob/app/services/user_context_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart'; // File ini di-generate oleh FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase dengan FlutterFire
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(
        NotificationService.onBackgroundMessage);
  } catch (e) {
    debugPrint("Firebase failed to initialize: $e");
    debugPrint("Pastikan sudah menjalankan 'flutterfire configure'");
  }

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  // Initialize UserContextService as a permanent service
  Get.put(UserContextService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sentral Nurulhuda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
    );
  }
}
