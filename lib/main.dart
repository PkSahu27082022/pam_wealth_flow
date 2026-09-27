import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/firebase_options.dart';

import 'AppManager/localization/app_language.dart';
import 'AppManager/service/chat_service.dart';
import 'AppManager/view/account/login_view.dart';
import 'AppManager/view/account/language_view.dart';
import 'AppManager/view/admin/admin_dashboard_view.dart';
import 'AppManager/view/dashboard/pam-wealth_dashboard.dart';
import 'AppManager/service/local_storage_service.dart';
import 'AppManager/service/deep_link_service.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool loggedIn = await LocalStorageService.isLoggedIn();
  final String? lang = await LocalStorageService.getLanguage();
  final bool isAdminUser = await LocalStorageService.isAdmin();

  runApp(ProviderScope(
    child: PAMApp(
      isLoggedIn: loggedIn,
      language: lang,
      isAdmin: isAdminUser,
    ),
  ));
}


class PAMApp extends ConsumerStatefulWidget {
  final bool isLoggedIn;
  final String? language;
  final bool isAdmin;

  const PAMApp({
    super.key,
    required this.isLoggedIn,
    this.language,
    this.isAdmin = false,
  });

  @override
  ConsumerState<PAMApp> createState() => _PAMAppState();
}

class _PAMAppState extends ConsumerState<PAMApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize Deep Links, App Language, and Online Status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialLang = widget.language ?? 'en';
      ref.read(appLanguageProvider.notifier).changeLanguage(initialLang);
      DeepLinkService().initDeepLinks(initialLang);
      if (widget.isLoggedIn) {
        ChatService().updateOnlineStatus(true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ChatService().updateOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      ChatService().updateOnlineStatus(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ChatService().updateOnlineStatus(false);
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    Widget initialHome;

    if (widget.isLoggedIn && widget.language != null) {
      if (widget.isAdmin) {
        initialHome = const AdminDashboardPage();
      } else {
        initialHome = WealthCenterPage(language: lang.languageCode);
      }
    } else if (widget.language != null) {
      initialHome = LoginPage(language: lang.languageCode);
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
