import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_language.dart';
import 'login_view.dart';
import 'sign_up_view.dart';

class LanguagePage extends ConsumerWidget {
  final String? referralCode;

  const LanguagePage({super.key, this.referralCode});

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);

  Future<void> selectLanguage(BuildContext context, WidgetRef ref, String language) async {
    // Update global language provider (also saves locally & in firestore)
    await ref.read(appLanguageProvider.notifier).changeLanguage(language);

    if (context.mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }

      if (referralCode != null) {
        // If coming from deep link with referral code, go to Sign Up forcefully
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(
              language: language,
              initialReferralCode: referralCode,
              isForced: true, // User cannot go back or skip
            ),
          ),
        );
      } else {
        // Normal flow go to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              language: language,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final lang = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.1),
            radius: 1.1,
            colors: [
              Color(0xFF171A1E),
              Color(0xFF0D1117),
              Color(0xFF090D13),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.22),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07111E),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/pam_logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.public,
                          size: 80,
                          color: gold,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  lang.selectLanguage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF555862),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _LanguageButton(
                          text: 'English',
                          isSelected: lang.languageCode == 'en',
                          onTap: () => selectLanguage(context, ref, 'en'),
                        ),
                        const SizedBox(height: 28),
                        _LanguageButton(
                          text: 'မြန်မာ (Burmese)',
                          isSelected: lang.languageCode == 'my',
                          onTap: () => selectLanguage(context, ref, 'my'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.text,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF3E3B2E) : const Color(0xFF292823),
          foregroundColor: LanguagePage.gold,
          side: BorderSide(
            color: LanguagePage.gold,
            width: isSelected ? 2.0 : 1.0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: LanguagePage.gold,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
