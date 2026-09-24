import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/reel_model.dart';
import '../../service/reel_service.dart';

final reelsProvider = AsyncNotifierProvider<ReelsViewModel, List<ReelModel>>(
  ReelsViewModel.new,
);

class ReelsViewModel extends AsyncNotifier<List<ReelModel>> {
  final ReelService _service = ReelService();

  @override
  Future<List<ReelModel>> build() async {
    await _service.seedReelsIfEmpty();
    return _service.getReels();
  }
}
