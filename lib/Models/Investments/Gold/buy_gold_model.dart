class BuyGoldRequest {
  final String userId;
  final double amount;
  final String type;

  BuyGoldRequest({
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
}
