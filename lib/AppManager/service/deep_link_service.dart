import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:pam_wealth_flow/AppManager/service/local_storage_service.dart';
import 'package:pam_wealth_flow/AppManager/view/account/sign_up_view.dart';
import 'package:pam_wealth_flow/AppManager/view/dashboard/pam-wealth_dashboard.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkService {

  // Updated AndroidManifest.xml to handle links from https://pam-wealth-flow.web.app.
  // Note: For this to work in production, you'll need to host a assetlinks.json file on your domain (https://pam-wealth-flow.web.app/.well-known/assetlinks.json) to verify ownership.


  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Change this to your actual domain
  static const String baseUrl = "https://pam-wealth-flow.web.app";
  static const String customScheme = "pamwealth";

  void initDeepLinks(BuildContext context, String language) {
    // Handle initial link if app was closed
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(context, uri, language);
      }
    });

    // Handle incoming links while app is running/backgrounded
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(context, uri, language);
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _handleDeepLink(BuildContext context, Uri uri, String language) async {
    debugPrint("Deep Link Received: $uri");

    // Check if user is already logged in
    final bool loggedIn = await LocalStorageService.isLoggedIn();

    if (loggedIn) {
      // If logged in, just go to dashboard
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => WealthCenterPage(language: language),
          ),
          (route) => false,
        );
      }
      return;
    }

    // Handle referral link: /register?ref=CODE or pamwealth://register?ref=CODE
    if (uri.path.contains('register') || uri.host == 'register') {
      final referralCode = uri.queryParameters['ref'];
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(
              language: language,
              initialReferralCode: referralCode,
            ),
          ),
        );
      }
    }
  }

  static Future<void> shareReferralLink({
    required String referralCode,
    required String appName,
    required String language,
  }) async {
    final String httpsLink = "$baseUrl/register?ref=$referralCode";
    //final String fallbackLink = "$customScheme://register?ref=$referralCode";

    // final String shareText = language == 'my'
    //     ? "မင်္ဂလာပါ။ $appName တွင် ကျွန်ုပ်နှင့်အတူ ပါဝင်ပြီး အကျိုးအမြတ်များ ရယူလိုက်ပါ။\n\nယခုပဲ စာရင်းသွင်းရန် (Website): $httpsLink\nသို့မဟုတ် App ဖြင့်ဖွင့်ရန်: $fallbackLink"
        //: "Hello! Join me on $appName and start earning profits.\n\nRegister now (Website): $httpsLink\nOr open in App: $fallbackLink";
    final String upperCode = referralCode.toUpperCase();

    final String shareText = language == 'my'
        ? "မင်္ဂလာပါ။ $appName တွင် ကျွန်ုပ်နှင့်အတူ ပါဝင်ပြီး အကျိုးအမြတ်များ ရယူလိုက်ပါ။\n\nယခုပဲ စာရင်းသွင်းရန် : $httpsLink\nကျွန်ုပ်၏ ရည်ညွှန်းကုဒ်\n$upperCode"
        : "Hello! Join me on $appName and start earning profits.\n\nRegister now: $httpsLink\nMy referral code\n$upperCode";

    await Share.share(shareText, subject: "Join $appName");
  }
}
