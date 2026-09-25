import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/firebase_options.dart';

import 'AppManager/view/account/login_view.dart';
import 'AppManager/view/account/language_view.dart';
import 'AppManager/view/dashboard/pam-wealth_dashboard.dart';
import 'AppManager/service/local_storage_service.dart';
import 'AppManager/service/deep_link_service.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool loggedIn = await LocalStorageService.isLoggedIn();
  final String? lang = await LocalStorageService.getLanguage();

  runApp(ProviderScope(
    child: PAMApp(
      isLoggedIn: loggedIn,
      language: lang,
    ),
  ));
}


class PAMApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? language;

  const PAMApp({
    super.key,
    required this.isLoggedIn,
    this.language,
  });

  @override
  State<PAMApp> createState() => _PAMAppState();
}

class _PAMAppState extends State<PAMApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Deep Links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initDeepLinks(widget.language ?? 'en');
    });
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget initialHome;

    if (widget.isLoggedIn && widget.language != null) {
      initialHome = WealthCenterPage(language: widget.language!);
    } else if (widget.language != null) {
      initialHome = LoginPage(language: widget.language!);
    } else {
      initialHome = const LanguagePage();
    }

    return MaterialApp(
      navigatorKey: DeepLinkService().navigatorKey, // Essential for deep link navigation
      debugShowCheckedModeBanner: false,
      title: 'PAM Wealth Flow',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C12),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9B337),
          brightness: Brightness.dark,
        ),
      ),
      home: initialHome,
    );
  }
}
