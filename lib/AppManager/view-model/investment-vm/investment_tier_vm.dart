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
    // This will fetch the investment plans once and cache them in-memory via Riverpod.
    // Future calls to ref.watch(investmentTiersProvider) will return the cached state instantly without any Firebase Firestore queries.
    return _service.getInvestmentTiers();
  }

  Future<void> refreshTiers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getInvestmentTiers());
  }
}
