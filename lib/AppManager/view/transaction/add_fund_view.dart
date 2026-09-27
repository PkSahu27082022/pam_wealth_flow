import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../localization/app_language.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/admin-vm/admin_vm.dart';
import '../../service/snackbar_service.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _hashController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _hashController.dispose();
    super.dispose();
  }

  Future<void> _submitDeposit(AppLanguage lang) async {
    final amountText = _amountController.text.trim();
    final hashText = _hashController.text.trim();

    if (amountText.isEmpty || hashText.isEmpty) {
      Alert.show(context, message: lang.tr('Please fill all fields', 'ကျေးဇူးပြု၍ ကွက်လပ်အားလုံး ဖြည့်ပါ'), type: AlertType.warning);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Alert.show(context, message: lang.tr('Invalid amount', 'ပမာဏ မှားယွင်းနေပါသည်'), type: AlertType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      final error = await ref.read(userViewModelProvider).createDepositRequest(
        uid: user.uid,
        userId: user.userId,
        userName: user.username,
        amount: amount,
        transactionHash: hashText,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (error == null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF161B22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(lang.requestSubmitted, style: const TextStyle(color: Color(0xFFE5B83B))),
              content: Text(
                lang.depositSentForApproval,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(lang.ok, style: const TextStyle(color: Color(0xFFE5B83B))),
                ),
              ],
            ),
          );
        } else {
          Alert.show(context, message: error, type: AlertType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1218);
    const cardBackgroundColor = Color(0xFF161B22);
    const goldColor = Color(0xFFE5B83B);
    const borderColor = Color(0xFF2A313D);

    final walletAsync = ref.watch(walletAddressProvider);
    final lang = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          lang.addFunds,
          style: const TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                lang.addFunds,
                style: const TextStyle(
                  color: goldColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang.scanQrOrCopyAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: walletAsync.when(
                  data: (addr) {
                    if (addr == null || addr.trim().isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Column(
                          children: [
                            const Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              lang.noPaymentWalletSet,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: addr,
                            version: QrVersions.auto,
                            size: 190.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SelectableText(
                          addr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: addr));
                            Alert.show(context, message: lang.walletAddressCopied, type: AlertType.success);
                          },
                          icon: const Icon(Icons.copy, color: goldColor, size: 16),
                          label: Text(
                            '${lang.copy} WALLET ADDRESS',
                            style: const TextStyle(
                              color: goldColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: goldColor, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator(color: goldColor)),
                  ),
                  error: (e, s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(lang.tr('Error loading wallet address', 'Wallet လိပ်စာ ရှာမတွေ့ပါ'), style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.paymentDetails,
                      style: const TextStyle(
                        color: goldColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _amountController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: lang.amountThb,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: goldColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _hashController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: lang.transactionHashId,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: goldColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _submitDeposit(lang),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          disabledBackgroundColor: Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text(
                              lang.submitDeposit,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
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
    );
  }
}
