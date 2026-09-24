import 'package:flutter/material.dart';

import '../../service/local_storage_service.dart';
import '../../service/auth_service.dart';
import 'login_view.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);

  Future<void> selectLanguage(BuildContext context, String language) async {
    // Save language locally
    await LocalStorageService.saveLanguage(language);
    
    // If user is already logged in, update it in firestore too
    final uid = await LocalStorageService.getUserUid();
    if (uid != null) {
      await AuthService().updateUserLanguage(uid, language);
    }

    if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // =========================================================
                  // TOP SPACE
                  // =========================================================
                  SizedBox(
                    height: size.height * 0.22,
                  ),

                  // =========================================================
                  // LOGO
                  // =========================================================
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

                  // =========================================================
                  // SELECT LANGUAGE
                  // =========================================================
                  const Text(
                    'Select Language',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================================================
                  // LANGUAGE CARD
                  // =========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        20,
                      ),
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
                          // =================================================
                          // ENGLISH
                          // =================================================
                          _LanguageButton(
                            text: 'English',
                            onTap: () {
                              selectLanguage(context, 'en');
                            },
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // BURMESE
                          // =================================================
                          _LanguageButton(
                            text: 'မြန်မာ (Burmese)',
                            onTap: () {
                              selectLanguage(context, 'my');
                            },
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
      ),
    );
  }
}

// ===========================================================================
// LANGUAGE BUTTON
// ===========================================================================

class _LanguageButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.text,
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
          backgroundColor: const Color(0xFF292823),

          foregroundColor: LanguagePage.gold,

          side: const BorderSide(
            color: LanguagePage.gold,
            width: 1,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          padding: EdgeInsets.zero,

          // Remove default elevation/overlay effects
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: LanguagePage.gold,
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}