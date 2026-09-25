import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/investment_tier_model.dart';
import '../../service/investment_service.dart';

final investmentTiersProvider = AsyncNotifierProvider<InvestmentTiersViewModel, List<InvestmentTierModel>>(
  InvestmentTiersViewModel.new,
);

class InvestmentTiersViewModel extends AsyncNotifier<List<InvestmentTierModel>> {
  final InvestmentService _service = InvestmentService();

  @override
  Future<List<InvestmentTierModel>> build() async {
    final list = await _service.getInvestmentTiers(forceRefresh: false);
    if (list.isEmpty) {
      await _service.seedInitialTiers();
      return _service.getInvestmentTiers(forceRefresh: true);
    }
    return list;
  }

  Future<void> refreshTiers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getInvestmentTiers(forceRefresh: true));
  }
}
