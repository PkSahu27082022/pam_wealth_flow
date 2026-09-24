import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/reel_model.dart';

class ReelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReelModel>> getReels() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reels').get();
      return snapshot.docs.map((doc) {
        return ReelModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching reels: $e");
      return [];
    }
  }

  /// Utility to seed 30 short public video loops into Firestore collection
  Future<void> seedReelsIfEmpty() async {
    try {
      final snap = await _firestore.collection('reels').limit(1).get();
      if (snap.docs.isNotEmpty) return; // Already seeded

      final batch = _firestore.batch();
      final urls = [
        'https://assets.testfiles.dev/video/sample-3s.mp4',
        'https://cdn.truefilesize.com/mp4/sample-portrait.mp4',
        'https://cdn.truefilesize.com/mp4/sample-5mb.mp4',
      ];

      for (int i = 0; i < 30; i++) {
        final docRef = _firestore.collection('reels').doc();
        batch.set(docRef, {
          'videoUrl': urls[i % urls.length],
          'thumbnail': '',
          'title': 'Public Reel Video #${i + 1}',
        });
      }
      await batch.commit();
    } catch (e) {
      print("Error seeding reels: $e");
    }
  }
}
