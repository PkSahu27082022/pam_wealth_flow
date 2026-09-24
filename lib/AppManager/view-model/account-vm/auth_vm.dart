import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/AppManager/service/auth_service.dart';

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(AuthViewModel.new);

class AuthViewModel extends AsyncNotifier<void> {
  final AuthService _authService = AuthService();

  @override
  Future<void> build() async {
    return;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    bool success = false;

    state = await AsyncValue.guard(() async {
      final error = await _authService.loginUser(
        email: email,
        password: password,
      );

      if (error != null) {
        throw Exception(error);
      }
      success = true;
    });

    return success;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    state = const AsyncValue.loading();
    bool success = false;

    state = await AsyncValue.guard(() async {
      final error = await _authService.registerUser(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        enteredReferralCode: referralCode,
      );

      if (error != null) {
        throw Exception(error);
      }
      success = true;
    });

    return success;
  }

  Future<bool> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    bool success = false;

    state = await AsyncValue.guard(() async {
      final error = await _authService.sendPasswordResetEmail(email);
      if (error != null) {
        throw Exception(error);
      }
      success = true;
    });

    return success;
  }
}
