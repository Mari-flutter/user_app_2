class SellGoldModel {
  final String userId;
  final double amount;
  final String type;

  SellGoldModel({
    required this.userId,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "amount": amount,
      "type": type,
    };
  }

  factory SellGoldModel.fromJson(Map<String, dynamic> json) {
    return SellGoldModel(
      userId: json["userId"],
      amount: (json["amount"] as num).toDouble(),
      type: json["type"],
    );
  }
}
