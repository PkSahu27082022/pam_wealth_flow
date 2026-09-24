import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/investment_tier_model.dart';

class InvestmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<InvestmentTierModel>> getInvestmentTiers() async {
    try {
      // Using get() will use the local cache if available and only fetch from server if needed/expired.
      // Firestore also has built-in persistence.
      QuerySnapshot snapshot = await _firestore
          .collection('investment_tiers')
          .orderBy('orderIndex')
          .get();

      return snapshot.docs.map((doc) {
        return InvestmentTierModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching investment tiers: $e");
      return [];
    }
  }

  /// One-time utility to seed the database with initial plans
  Future<void> seedInitialTiers() async {
    final tiers = [
      {'title': 'Internship', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '0 THB', 'orderIndex': 0},
      {'title': 'SV1', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '500 THB', 'orderIndex': 1},
      {'title': 'SV2', 'dailyTask': '3 Tasks', 'payPerTask': '12 THB', 'dailyRoi': '36 THB', 'investmentAmount': '1200 THB', 'orderIndex': 2},
      {'title': 'SV3', 'dailyTask': '6 Tasks', 'payPerTask': '20 THB', 'dailyRoi': '120 THB', 'investmentAmount': '3900 THB', 'orderIndex': 3},
      {'title': 'GV1', 'dailyTask': '12 Tasks', 'payPerTask': '30 THB', 'dailyRoi': '360 THB', 'investmentAmount': '11000 THB', 'orderIndex': 4},
      {'title': 'GV2', 'dailyTask': '25 Tasks', 'payPerTask': '40 THB', 'dailyRoi': '1000 THB', 'investmentAmount': '28000 THB', 'orderIndex': 5},
      {'title': 'GV3', 'dailyTask': '30 Tasks', 'payPerTask': '85 THB', 'dailyRoi': '2550 THB', 'investmentAmount': '70000 THB', 'orderIndex': 6},
      {'title': 'GO', 'dailyTask': '5 Videos', 'payPerTask': '18 THB', 'dailyRoi': '90 THB', 'investmentAmount': '3,000 THB', 'orderIndex': 7},
      {'title': 'PLUS', 'dailyTask': '5 Videos', 'payPerTask': '36 THB', 'dailyRoi': '180 THB', 'investmentAmount': '6,000 THB', 'orderIndex': 8},
      {'title': 'PRO', 'dailyTask': '5 Videos', 'payPerTask': '54 THB', 'dailyRoi': '270 THB', 'investmentAmount': '9,000 THB', 'orderIndex': 9},
      {'title': 'MAX', 'dailyTask': '5 Videos', 'payPerTask': '84 THB', 'dailyRoi': '420 THB', 'investmentAmount': '12,000 THB', 'orderIndex': 10},
      {'title': 'ULTRA', 'dailyTask': '5 Videos', 'payPerTask': '102 THB', 'dailyRoi': '510 THB', 'investmentAmount': '15,000 THB', 'orderIndex': 11},
      {'title': 'INFINITY', 'dailyTask': '5 Videos', 'payPerTask': '204 THB', 'dailyRoi': '1,020 THB', 'investmentAmount': '30,000 THB', 'orderIndex': 12},
    ];

    final batch = _firestore.batch();
    for (var tier in tiers) {
      final docRef = _firestore.collection('investment_tiers').doc();
      batch.set(docRef, tier);
    }
    await batch.commit();
  }
}
