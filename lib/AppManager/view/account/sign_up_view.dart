import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/view-model/account-vm/auth_vm.dart';
import '../../service/snackbar_service.dart';
import 'login_view.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final String language;
  final String? initialReferralCode;
  final bool isForced;

  const SignUpPage({
    super.key,
    required this.language,
    this.initialReferralCode,
    this.isForced = false,
  });

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color fieldColor = Color(0xFF18191F);
  static const Color borderColor = Color(0xFF50525A);

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

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
        message: tr('Sign up successful', 'စာရင်းသွင်းခြင်း အောင်မြင်ပါသည်'),
        type: AlertType.success,
      );
      goToLogin();
    } else if (mounted) {
      final state = ref.read(authViewModelProvider);
      if (state.hasError) {
        final errorMessage = state.error.toString().replaceAll("Exception: ", "");
        Alert.show(context, message: errorMessage, type: AlertType.error);
      }
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(language: widget.language)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return PopScope(
      canPop: !widget.isForced,
      child: Scaffold(
        backgroundColor: background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.1,
              colors: [Color(0xFF171A1E), Color(0xFF0D1117), Color(0xFF090D13)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (!widget.isForced)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: gold, size: 31),
                        ),
                      SizedBox(width: widget.isForced ? 0 : 18),
                      Text(
                        tr('SIGN UP', 'စာရင်းသွင်းရန်'),
                        style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/pam_logo.jpeg',
                    width: 95,
                    height: 95,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, size: 55, color: gold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25, 22, 25, 20),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF555862), width: 1.2),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Text(
                            tr('Register for Wealth Flow', 'Wealth Flow အတွက် စာရင်းသွင်းပါ'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 20),
                          _SignupField(
                            controller: usernameController,
                            hintText: tr('Username', 'အသုံးပြုသူအမည်'),
                            icon: Icons.person,
                            validator: (value) => value == null || value.trim().isEmpty ? tr('Enter username', 'အသုံးပြုသူအမည် ထည့်ပါ') : null,
                          ),
                          const SizedBox(height: 14),
                          _SignupField(
                            controller: emailController,
                            hintText: tr('Email Address', 'အီးမေးလ်လိပ်စာ'),
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return tr('Enter email', 'အီးမေးလ် ထည့်ပါ');
                              if (!value.contains('@')) return tr('Enter valid email', 'မှန်ကန်သော အီးမေးလ် ထည့်ပါ');
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _SignupField(
                            controller: passwordController,
                            hintText: tr('Password', 'စကားဝှက်'),
                            icon: Icons.lock,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => obscurePassword = !obscurePassword),
                              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white, size: 22),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return tr('Enter password', 'စကားဝှက် ထည့်ပါ');
                              if (value.length < 6) return tr('Minimum 6 characters', 'အနည်းဆုံး စာလုံး ၆ လုံး ထည့်ပါ');
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _SignupField(
                            controller: confirmPasswordController,
                            hintText: tr('Confirm Password', 'စကားဝှက် အတည်ပြုပါ'),
                            icon: Icons.lock_reset,
                            obscureText: obscureConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                              icon: Icon(obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white, size: 22),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return tr('Confirm password', 'စကားဝှက် အတည်ပြုပါ');
                              if (value != passwordController.text) return tr('Passwords do not match', 'စကားဝှက်များ မကိုက်ညီပါ');
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _SignupField(
                            controller: referralController,
                            hintText: tr('Referral (Optional)', 'ရည်ညွှန်းကုဒ် (ရှိလျှင်)'),
                            icon: Icons.card_giftcard,
                            enabled: !widget.isForced, // Lock if forced from deep link
                            validator: (value) => null,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                disabledBackgroundColor: gold.withOpacity(0.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                              ),
                              child: isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                                  : Text(tr('SIGN UP', 'စာရင်းသွင်းမည်'), style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!widget.isForced)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr('Already have an account?', 'အကောင့်ရှိပြီးသားလား?'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 9),
                        GestureDetector(
                          onTap: goToLogin,
                          child: Text(tr('LOGIN', 'ဝင်ရောက်မည်'), style: const TextStyle(color: gold, fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const _SignupField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: const Color(0xFFDDB83A),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFE0E0E3), fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFFDDB83A), size: 22),
        suffixIcon: suffixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: const Color(0xFF18191F),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.white10, width: 1.3)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFF50525A), width: 1.3)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFDDB83A), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.redAccent, width: 1.3)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }
}
