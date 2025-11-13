class MyInvestmentPayment {
  final String id;
  final double amount;
  final String paymentDate;
  final bool isLate;

  MyInvestmentPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.isLate,
  });

  factory MyInvestmentPayment.fromJson(Map<String, dynamic> json) {
    return MyInvestmentPayment(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] ?? '',
      isLate: json['isLate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'paymentDate': paymentDate,
    'isLate': isLate,
  };
}

class MyInvestmentGoldItem {
  final String id;
  final double goldValue;

  MyInvestmentGoldItem({
    required this.id,
    required this.goldValue,
  });

  factory MyInvestmentGoldItem.fromJson(Map<String, dynamic> json) {
    return MyInvestmentGoldItem(
      id: json['id'] ?? '',
      goldValue: (json['goldValue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goldValue': goldValue,
  };
}

class MyInvestmentJoinedScheme {
  final String schemeId;
  final String schemeName;
  final double totalValue;
  final int duration;
  final double contribution;
  final String dueDate;
  final double estimateValue;
  final double charges;
  final String memberId;
  final String joinDate;
  final bool isComplete;
  final double totalPaid;
  final String nextDueDate;
  final double schemeGoldSum;
  final double schemePaymentSum;
  final List<MyInvestmentPayment> payments;
  final List<MyInvestmentGoldItem> golds;

  MyInvestmentJoinedScheme({
    required this.schemeId,
    required this.schemeName,
    required this.totalValue,
    required this.duration,
    required this.contribution,
    required this.dueDate,
    required this.estimateValue,
    required this.charges,
    required this.memberId,
    required this.joinDate,
    required this.isComplete,
    required this.totalPaid,
    required this.nextDueDate,
    required this.schemeGoldSum,
    required this.schemePaymentSum,
    required this.payments,
    required this.golds,
  });

  factory MyInvestmentJoinedScheme.fromJson(Map<String, dynamic> json) {
    return MyInvestmentJoinedScheme(
      schemeId: json['schemeId'] ?? '',
      schemeName: json['schemeName'] ?? '',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      contribution: (json['contribution'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
      estimateValue: (json['estimateValue'] ?? 0).toDouble(),
      charges: (json['charges'] ?? 0).toDouble(),
      memberId: json['memberId'] ?? '',
      joinDate: json['joinDate'] ?? '',
      isComplete: json['isComplete'] ?? false,
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      nextDueDate: json['nextDueDate'] ?? '',
      schemeGoldSum: (json['schemeGoldSum'] ?? 0).toDouble(),
      schemePaymentSum: (json['schemePaymentSum'] ?? 0).toDouble(),
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => MyInvestmentPayment.fromJson(e))
          .toList(),
      golds: (json['golds'] as List<dynamic>? ?? [])
          .map((e) => MyInvestmentGoldItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemeId': schemeId,
    'schemeName': schemeName,
    'totalValue': totalValue,
    'duration': duration,
    'contribution': contribution,
    'dueDate': dueDate,
    'estimateValue': estimateValue,
    'charges': charges,
    'memberId': memberId,
    'joinDate': joinDate,
    'isComplete': isComplete,
    'totalPaid': totalPaid,
    'nextDueDate': nextDueDate,
    'schemeGoldSum': schemeGoldSum,
    'schemePaymentSum': schemePaymentSum,
    'payments': payments.map((e) => e.toJson()).toList(),
    'golds': golds.map((e) => e.toJson()).toList(),
  };
}

class MyInvestmentGoldModel {
  final int activeSchemeCount;
  final int completedSchemeCount;
  final double totalGoldValue;
  final double totalAmountPaid;
  final double currentGoldPrice;
  final double currentGoldWorth;
  final List<MyInvestmentJoinedScheme> joinedSchemes;

  MyInvestmentGoldModel({
    required this.activeSchemeCount,
    required this.completedSchemeCount,
    required this.totalGoldValue,
    required this.totalAmountPaid,
    required this.currentGoldPrice,
    required this.currentGoldWorth,
    required this.joinedSchemes,
  });

  factory MyInvestmentGoldModel.fromJson(Map<String, dynamic> json) {
    return MyInvestmentGoldModel(
      activeSchemeCount: json['activeSchemeCount'] ?? 0,
      completedSchemeCount: json['completedSchemeCount'] ?? 0,
      totalGoldValue: (json['totalGoldValue'] ?? 0).toDouble(),
      totalAmountPaid: (json['totalAmountPaid'] ?? 0).toDouble(),
      currentGoldPrice: (json['currentGoldPrice'] ?? 0).toDouble(),
      currentGoldWorth: (json['currentGoldWorth'] ?? 0).toDouble(),
      joinedSchemes: (json['joinedSchemes'] as List<dynamic>? ?? [])
          .map((e) => MyInvestmentJoinedScheme.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'activeSchemeCount': activeSchemeCount,
    'completedSchemeCount': completedSchemeCount,
    'totalGoldValue': totalGoldValue,
    'totalAmountPaid': totalAmountPaid,
    'currentGoldPrice': currentGoldPrice,
    'currentGoldWorth': currentGoldWorth,
    'joinedSchemes': joinedSchemes.map((e) => e.toJson()).toList(),
  };
}
