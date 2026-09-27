import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../service/admin_service.dart';
import '../../model/deposit_request_model.dart';
import '../../model/user_model.dart';

final adminServiceProvider = Provider((ref) => AdminService());

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(adminServiceProvider).getAdminStats();
});

final allUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(adminServiceProvider).getAllUsers();
});

final walletAddressProvider = FutureProvider.autoDispose<String?>((ref) async {
  return ref.watch(adminServiceProvider).getWalletAddress();
});

final depositRequestsProvider = StreamProvider.family<List<DepositRequestModel>, DepositStatus>((ref, status) {
  return ref.watch(adminServiceProvider).getDepositRequests(status);
});

final adminViewModelProvider = Provider((ref) => AdminViewModel(ref));

class AdminViewModel {
  final Ref _ref;
  AdminViewModel(this._ref);

  Future<void> updateWallet(String address) async {
    await _ref.read(adminServiceProvider).updateWalletAddress(address);
    _ref.invalidate(walletAddressProvider);
  }

  Future<String?> manualDeposit(String uid, double amount) async {
    final result = await _ref.read(adminServiceProvider).manualDeposit(uid, amount);
    if (result == null) {
      _ref.invalidate(adminStatsProvider);
      _ref.invalidate(allUsersProvider);
    }
    return result;
  }

  Future<String?> processRequest(String requestId, bool approve) async {
    final result = await _ref.read(adminServiceProvider).processDepositRequest(requestId, approve);
    if (result == null) {
      _ref.invalidate(adminStatsProvider);
      _ref.invalidate(allUsersProvider);
    }
    return result;
  }
}
