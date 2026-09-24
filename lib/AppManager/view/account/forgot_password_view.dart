import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/service/snackbar_service.dart';
import 'package:pam_wealth_flow/AppManager/view-model/account-vm/auth_vm.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String language;

  const ForgotPasswordPage({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);
  static const Color fieldColor = Color(0xFF181A21);

  bool get isBurmese => widget.language == 'my';

  String tr(String english, String burmese) => isBurmese ? burmese : english;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    final success = await ref.read(authViewModelProvider.notifier).forgotPassword(
      emailController.text.trim(),
    );

    if (success && mounted) {
      Alert.show(
        context,
        message: tr(
          'Password reset email sent. Please check your inbox.',
          'စကားဝှက်ပြန်လည်သတ်မှတ်ရန် အီးမေးလ် ပို့လိုက်ပါပြီ။ ကျေးဇူးပြု၍ စစ်ဆေးပါ။',
        ),
        type: AlertType.success,
      );
      Navigator.pop(context);
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

    return Scaffold(
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
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: gold, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07111E),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Image.asset(
                        'assets/pam_logo.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.public, size: 60, color: gold),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 28, 30, 30),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFF555862), width: 1.2),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              tr('Reset Password', 'စကားဝှက် ပြန်လည်သတ်မှတ်ပါ'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tr(
                                'Enter your email to receive a reset link',
                                'ပြန်လည်သတ်မှတ်ရန် လင့်ခ်လက်ခံရယူရန် အီးမေးလ်ထည့်ပါ',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: tr('Email Address', 'အီးမေးလ်လိပ်စာ'),
                                hintStyle: const TextStyle(color: Color(0xFFE1E1E4), fontSize: 15),
                                prefixIcon: const Icon(Icons.email, color: gold, size: 22),
                                filled: true,
                                fillColor: fieldColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(color: Color(0xFF555861), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(color: gold, width: 1.2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return tr('Enter email', 'အီးမေးလ် ထည့်ပါ');
                                if (!value.contains('@')) return tr('Enter valid email', 'မှန်ကန်သော အီးမေးလ် ထည့်ပါ');
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : Text(
                                        tr('SEND LINK', 'လင့်ခ် ပို့မည်'),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
