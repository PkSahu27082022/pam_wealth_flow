class InvestmentTierModel {
  final String id;
  final String title;
  final String dailyTask;
  final String payPerTask;
  final String dailyRoi;
  final String investmentAmount;
  final int orderIndex;

  InvestmentTierModel({
    required this.id,
    required this.title,
    required this.dailyTask,
    required this.payPerTask,
    required this.dailyRoi,
    required this.investmentAmount,
    required this.orderIndex,
  });

  factory InvestmentTierModel.fromMap(String id, Map<String, dynamic> map) {
    return InvestmentTierModel(
      id: id,
      title: map['title'] ?? '',
      dailyTask: map['dailyTask'] ?? '',
      payPerTask: map['payPerTask'] ?? '',
      dailyRoi: map['dailyRoi'] ?? '',
      investmentAmount: map['investmentAmount'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dailyTask': dailyTask,
      'payPerTask': payPerTask,
      'dailyRoi': dailyRoi,
      'investmentAmount': investmentAmount,
      'orderIndex': orderIndex,
    };
  }
}
