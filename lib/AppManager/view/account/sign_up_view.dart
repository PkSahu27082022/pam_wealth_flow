import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/view-model/account-vm/auth_vm.dart';

import '../../service/snackbar_service.dart';
import 'login_view.dart';


class SignUpPage extends ConsumerStatefulWidget {
  final String language;
  final String? initialReferralCode;

  const SignUpPage({
    super.key,
    required this.language,
    this.initialReferralCode,
  });

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color fieldColor = Color(0xFF18191F);
  static const Color borderColor = Color(0xFF50525A);

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ===========================================================================
  // TRANSLATION
  // ===========================================================================

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    if (widget.initialReferralCode != null) {
      referralController.text = widget.initialReferralCode!;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // SIGN UP VIA RIVERPOD VIEWMODEL
  // ===========================================================================

  Future<void> signUp() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authViewModelProvider.notifier).register(
      username: usernameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      referralCode: referralController.text,
    );

    if (success && mounted) {
      Alert.show(
        context,
        message: tr(
          'Sign up successful',
          'စာရင်းသွင်းခြင်း အောင်မြင်ပါသည်',
        ),
        type: AlertType.success,
      );

      goToLogin();
    } else if (mounted) {
      final state = ref.read(authViewModelProvider);
      if (state.hasError) {
        final errorMessage = state.error.toString().replaceAll("Exception: ", "");
        Alert.show(
          context,
          message: errorMessage,
          type: AlertType.error,
        );
      }
    }
  }

  // ===========================================================================
  // LOGIN
  // ===========================================================================

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          language: widget.language,
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;



    return Scaffold(
      backgroundColor: background,
      // Removed resizeToAvoidBottomInset: false so the screen adjusts naturally to the keyboard
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                // ===============================================================
                // HEADER
                // ===============================================================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: gold,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      tr(
                        'SIGN UP',
                        'စာရင်းသွင်းရန်',
                      ),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===============================================================
                // LOGO
                // ===============================================================
                Image.asset(
                  'assets/pam_logo.jpeg',
                  width: 95,
                  height: 95,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.public,
                      size: 55,
                      color: gold,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ===============================================================
                // SIGN UP CARD
                // ===============================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 22, 25, 20),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF555862),
                      width: 1.2,
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // ===================================================
                        // TITLE
                        // ===================================================
                        Text(
                          tr(
                            'Register for Wealth Flow',
                            'Wealth Flow အတွက် စာရင်းသွင်းပါ',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ===================================================
                        // USERNAME
                        // ===================================================
                        _SignupField(
                          controller: usernameController,
                          hintText: tr('Username', 'အသုံးပြုသူအမည်'),
                          icon: Icons.person,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return tr('Enter username', 'အသုံးပြုသူအမည် ထည့်ပါ');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ===================================================
                        // EMAIL
                        // ===================================================
                        _SignupField(
                          controller: emailController,
                          hintText: tr('Email Address', 'အီးမေးလ်လိပ်စာ'),
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return tr('Enter email', 'အီးမေးလ် ထည့်ပါ');
                            }
                            if (!value.contains('@')) {
                              return tr('Enter valid email', 'မှန်ကန်သော အီးမေးလ် ထည့်ပါ');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ===================================================
                        // PASSWORD
                        // ===================================================
                        _SignupField(
                          controller: passwordController,
                          hintText: tr('Password', 'စကားဝှက်'),
                          icon: Icons.lock,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr('Enter password', 'စကားဝှက် ထည့်ပါ');
                            }
                            if (value.length < 6) {
                              return tr('Minimum 6 characters', 'အနည်းဆုံး စာလုံး ၆ လုံး ထည့်ပါ');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ===================================================
                        // CONFIRM PASSWORD
                        // ===================================================
                        _SignupField(
                          controller: confirmPasswordController,
                          hintText: tr('Confirm Password', 'စကားဝှက် အတည်ပြုပါ'),
                          icon: Icons.lock_reset,
                          obscureText: obscureConfirmPassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword = !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr('Confirm password', 'စကားဝှက် အတည်ပြုပါ');
                            }
                            if (value != passwordController.text) {
                              return tr('Passwords do not match', 'စကားဝှက်များ မကိုက်ညီပါ');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ===================================================
                        // REFERRAL
                        // ===================================================
                        _SignupField(
                          controller: referralController,
                          hintText: tr('Referral (Optional)', 'ရည်ညွှန်းကုဒ် (ရှိလျှင်)'),
                          icon: Icons.card_giftcard,
                          textInputAction: TextInputAction.done,
                          validator: (value) => null,
                        ),

                        const SizedBox(height: 22),

                        // ===================================================
                        // SIGN UP BUTTON
                        // ===================================================
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              disabledBackgroundColor: gold.withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                                : Text(
                              tr(
                                'SIGN UP',
                                'စာရင်းသွင်းမည်',
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===============================================================
                // LOGIN LINK
                // ===============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tr(
                        'Already have an account?',
                        'အကောင့်ရှိပြီးသားလား?',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 9),
                    GestureDetector(
                      onTap: goToLogin,
                      child: Text(
                        tr(
                          'LOGIN',
                          'ဝင်ရောက်မည်',
                        ),
                        style: const TextStyle(
                          color: gold,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SIGN UP FIELD
// ===========================================================================

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const _SignupField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      cursorColor: _SignUpPageState.gold,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFE0E0E3),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: _SignUpPageState.gold,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: _SignUpPageState.fieldColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: _SignUpPageState.borderColor,
            width: 1.3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: _SignUpPageState.gold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.3,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}