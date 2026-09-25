import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/investment_tier_model.dart';

class InvestmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cacheKey = 'cached_investment_tiers';

  Future<List<InvestmentTierModel>> getInvestmentTiers({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          final List<dynamic> decoded = jsonDecode(cachedData);
          return decoded.map((item) => InvestmentTierModel.fromMap(item['id'], item)).toList();
        }
      }

      QuerySnapshot snapshot = await _firestore
          .collection('investment_tiers')
          .orderBy('orderIndex')
          .get();

      final tiers = snapshot.docs.map((doc) {
        return InvestmentTierModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // Save to local cache
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(tiers.map((t) => {
        ...t.toMap(),
        'id': t.id,
      }).toList());
      await prefs.setString(_cacheKey, encoded);

      return tiers;
    } catch (e) {
      print("Error fetching investment tiers: $e");
      return [];
    }
  }

  /// One-time utility to seed the database with initial plans including new ones
  Future<void> seedInitialTiers() async {
    final tiers = [
      {'title': 'Internship', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '0 THB', 'orderIndex': 0},
      {'title': 'SV1', 'dailyTask': '3 Tasks', 'payPerTask': '10 THB', 'dailyRoi': '30 THB', 'investmentAmount': '500 THB', 'orderIndex': 1},
      {'title': 'SV2', 'dailyTask': '3 Tasks', 'payPerTask': '12 THB', 'dailyRoi': '36 THB', 'investmentAmount': '1200 THB', 'orderIndex': 2},
      {'title': 'SV3', 'dailyTask': '6 Tasks', 'payPerTask': '20 THB', 'dailyRoi': '120 THB', 'investmentAmount': '3900 THB', 'orderIndex': 3},

      // New plans from image
      {'title': 'GO', 'dailyTask': '5 Videos', 'payPerTask': '18 THB', 'dailyRoi': '90 THB', 'investmentAmount': '3,000 THB', 'orderIndex': 4},
      {'title': 'PLUS', 'dailyTask': '5 Videos', 'payPerTask': '36 THB', 'dailyRoi': '180 THB', 'investmentAmount': '6,000 THB', 'orderIndex': 5},
      {'title': 'PRO', 'dailyTask': '5 Videos', 'payPerTask': '54 THB', 'dailyRoi': '270 THB', 'investmentAmount': '9,000 THB', 'orderIndex': 6},
      {'title': 'MAX', 'dailyTask': '5 Videos', 'payPerTask': '84 THB', 'dailyRoi': '420 THB', 'investmentAmount': '12,000 THB', 'orderIndex': 7},
      {'title': 'ULTRA', 'dailyTask': '5 Videos', 'payPerTask': '102 THB', 'dailyRoi': '510 THB', 'investmentAmount': '15,000 THB', 'orderIndex': 8},
      {'title': 'INFINITY', 'dailyTask': '5 Videos', 'payPerTask': '204 THB', 'dailyRoi': '1,020 THB', 'investmentAmount': '30,000 THB', 'orderIndex': 9},
    ];

    final batch = _firestore.batch();
    // First clear existing to avoid duplicates if re-seeding
    final existing = await _firestore.collection('investment_tiers').get();
    for (var doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (var tier in tiers) {
      final docRef = _firestore.collection('investment_tiers').doc();
      batch.set(docRef, tier);
    }
    await batch.commit();

    // Clear local cache after seeding to ensure fresh data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
