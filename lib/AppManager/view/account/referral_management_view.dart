import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../service/snackbar_service.dart';

class ReferralManagementPage extends ConsumerStatefulWidget {
  final String language;

  const ReferralManagementPage({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<ReferralManagementPage> createState() => _ReferralManagementPageState();
}

class _ReferralManagementPageState extends ConsumerState<ReferralManagementPage> {
  final TextEditingController _referralController = TextEditingController();
  bool _isSubmitting = false;

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);
  static const Color cardColor = Color(0xFF171920);

  String tr(String english, String burmese) {
    return widget.language == 'my' ? burmese : english;
  }

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    final code = _referralController.text.trim();
    if (code.isEmpty) {
      Alert.show(context, message: tr('Please enter a referral code', 'ကျေးဇူးပြု၍ ရည်ညွှန်းကုဒ်ထည့်ပါ'), type: AlertType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final error = await ref.read(userViewModelProvider).addReferrer(uid, code);
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (error == null) {
          Alert.show(context, message: tr('Referral added successfully!', 'ရည်ညွှန်းကုဒ် အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ'), type: AlertType.success);
          _referralController.clear();
        } else {
          Alert.show(context, message: error, type: AlertType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('Earn More', 'ပိုမိုရရှိရန်'),
          style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [Color(0xFF15191F), Color(0xFF0D1117), Color(0xFF090D13)],
          ),
        ),
        child: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: CircularProgressIndicator(color: gold));

            final hasReferrer = user.referredBy.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.shield, color: gold, size: 80),
                  const SizedBox(height: 25),
                  Text(
                    tr('Referral Program', 'ရည်ညွှန်းအစီအစဉ်'),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('Enter a referral code to unlock more earnings and connect with your team.', 'ပိုမိုဝင်ငွေရရှိရန်နှင့် သင့်အဖွဲ့နှင့် ချိတ်ဆက်ရန် ရည်ညွှန်းကုဒ်ကို ထည့်သွင်းပါ။'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF555862), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasReferrer ? tr('Active Referrer', 'လက်ရှိ ရည်ညွှန်းသူ') : tr('Enter Referral Code', 'ရည်ညွှန်းကုဒ် ထည့်ပါ'),
                          style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        if (hasReferrer)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181A21),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.referredBy,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              TextField(
                                controller: _referralController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: tr('Referral Code', 'ရည်ညွှန်းကုဒ်'),
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: const Color(0xFF181A21),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF555861))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: gold)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitReferral,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gold,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                      : Text(tr('SAVE CODE', 'ကုဒ်သိမ်းဆည်းမည်'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: gold)),
          error: (e, s) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }
}
