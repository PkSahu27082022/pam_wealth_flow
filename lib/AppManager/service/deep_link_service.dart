import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:pam_wealth_flow/AppManager/service/local_storage_service.dart';
import 'package:pam_wealth_flow/AppManager/view/account/language_view.dart';
import 'package:pam_wealth_flow/AppManager/view/dashboard/pam-wealth_dashboard.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Use a Navigator Key for reliable navigation from the service
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String baseUrl = "https://cloudsms-e9900.web.app";

  void initDeepLinks(String language) {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri, language);
      }
    });

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri, language);
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _handleDeepLink(Uri uri, String language) async {
    debugPrint("Deep Link Received: $uri");

    final bool loggedIn = await LocalStorageService.isLoggedIn();

    if (loggedIn) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WealthCenterPage(language: language)),
        (route) => false,
      );
      return;
    }

    if (uri.path.contains('register') || uri.host == 'register' || uri.scheme == 'pamwealth') {
      final referralCode = uri.queryParameters['ref'];
      
      // Step 1: Force Language Selection
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LanguagePage(referralCode: referralCode)),
        (route) => false,
      );
    }
  }

  static Future<void> shareReferralLink({
    required String referralCode,
    required String appName,
    required String language,
  }) async {
    final String httpsLink = "$baseUrl/register?ref=$referralCode";
    final String upperCode = referralCode.toUpperCase();

    final String shareText = language == 'my'
        ? "မင်္ဂလာပါ။ $appName တွင် ကျွန်ုပ်နှင့်အတူ ပါဝင်ပြီး အကျိုးအမြတ်များ ရယူလိုက်ပါ။\n\nယခုပဲ စာရင်းသွင်းရန် : $httpsLink\nကျွန်ုပ်၏ ရည်ညွှန်းကုဒ်\n$upperCode"
        : "Hello! Join me on $appName and start earning profits.\n\nRegister now: $httpsLink\nMy referral code\n$upperCode";

    await Share.share(shareText, subject: "Join $appName");
  }
}
