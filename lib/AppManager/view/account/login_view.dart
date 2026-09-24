import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/service/snackbar_service.dart';
import 'package:pam_wealth_flow/AppManager/view-model/account-vm/auth_vm.dart';
import 'package:pam_wealth_flow/AppManager/view/account/forgot_password_view.dart';
import 'package:pam_wealth_flow/AppManager/view/account/sign_up_view.dart';
import 'package:pam_wealth_flow/AppManager/view/dashboard/pam-wealth_dashboard.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String language;

  const LoginPage({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);

  bool get isBurmese => widget.language == 'my';

  String get secureSignIn => isBurmese ? 'လုံခြုံစွာ ဝင်ရောက်ပါ' : 'Secure Sign In';
  String get accountEmail => isBurmese ? 'အကောင့် / အီးမေးလ်' : 'Account / Email';
  String get password => isBurmese ? 'စကားဝှက်' : 'Password';
  String get forgotPassword => isBurmese ? 'စကားဝှက် မေ့နေပါသလား?' : 'Forgot Password?';
  String get loginText => isBurmese ? 'ဝင်ရောက်ရန်' : 'LOGIN';
  String get alreadyHaveAccount => isBurmese ? 'အကောင့်မရှိသေးပါလား? ' : "Don't have an account? ";
  String get registerNow => isBurmese ? 'ယခု စာရင်းသွင်းပါ' : 'Register Now';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final passwordValue = passwordController.text.trim();

    final success = await ref.read(authViewModelProvider.notifier).login(
      email: email,
      password: passwordValue,
    );

    if (success && mounted) {
      Alert.show(
        context,
        message: isBurmese ? 'ဝင်ရောက်ခြင်း အောင်မြင်ပါသည်' : 'Login successful',
        type: AlertType.success,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WealthCenterPage(
            language: widget.language,
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
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
                const SizedBox(height: 35),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07111E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Image.asset(
                    'assets/pam_logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.public,
                          size: 65,
                          color: gold,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'PAM Wealth Flow',
                  style: textTheme.titleLarge?.copyWith(
                    color: gold,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Intelligent Wealth Flow',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(40, 28, 40, 30),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFF555862),
                        width: 1.2,
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            secureSignIn,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: isBurmese ? 18 : 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _InputField(
                            controller: emailController,
                            hintText: accountEmail,
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isBurmese ? 'အီးမေးလ် ထည့်ပါ' : 'Enter email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _InputField(
                            controller: passwordController,
                            hintText: password,
                            icon: Icons.lock,
                            obscureText: obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isBurmese ? 'စကားဝှက် ထည့်ပါ' : 'Enter password';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white70,
                                size: 23,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage(
                                      language: widget.language,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                forgotPassword,
                                textAlign: TextAlign.right,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: gold,
                                  fontSize: isBurmese ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      loginText,
                                      textAlign: TextAlign.center,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: Colors.black,
                                        fontSize: isBurmese ? 15 : 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          alreadyHaveAccount,
                          textAlign: TextAlign.right,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: isBurmese ? 12 : 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(
                                language: widget.language,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          registerNow,
                          style: textTheme.bodyMedium?.copyWith(
                            color: gold,
                            fontSize: isBurmese ? 12 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFDDB83A);
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontSize: 15,
      ),
      cursorColor: gold,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFE1E1E4),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: gold,
          size: 23,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF181A21),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFF555861),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: gold,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
