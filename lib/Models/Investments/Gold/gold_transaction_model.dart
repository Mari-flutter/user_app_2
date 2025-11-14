class GoldTransaction {
  final String id;
  final String type; // "buy" or "sell"
  final double amount;
  final double goldRate;
  final double goldGrams;
  final DateTime dateTime;

  // Buy-only fields
  final String? orderId;
  final String? paymentId;
  final bool? status;

  GoldTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.goldRate,
    required this.goldGrams,
    required this.dateTime,
    this.orderId,
    this.paymentId,
    this.status,
  });

  // BUY factory
  factory GoldTransaction.fromBuy(Map<String, dynamic> json) {
    return GoldTransaction(
      id: json["id"],
      type: "buy",
      amount: json["amount"]?.toDouble() ?? 0,
      goldRate: json["goldRate"]?.toDouble() ?? 0,
      goldGrams: json["goldGrams"]?.toDouble() ?? 0,
      dateTime: DateTime.parse(json["dateTime"]),
      orderId: json["orderId"],
      paymentId: json["paymentID"],
      status: json["status"],
    );
  }

  // SELL factory
  factory GoldTransaction.fromSell(Map<String, dynamic> json) {
    return GoldTransaction(
      id: json["id"],
      type: "sell",
      amount: json["amount"]?.toDouble() ?? 0,
      goldRate: json["goldRate"]?.toDouble() ?? 0,
      goldGrams: json["grams"]?.toDouble() ?? 0,
      dateTime: DateTime.parse(json["dateTime"]),
    );
  }
}
