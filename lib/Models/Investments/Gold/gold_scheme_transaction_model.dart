class GoldSchemeTransaction {
  final String id;
  final String paymentId;
  final String orderId;
  final double amount;
  final DateTime dateTime;
  final bool status;
  final String schemeName;

  GoldSchemeTransaction({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.dateTime,
    required this.status,
    required this.schemeName,
  });

  factory GoldSchemeTransaction.fromJson(Map<String, dynamic> json) {
    return GoldSchemeTransaction(
      id: json["id"],
      paymentId: json["paymentID"],
      orderId: json["orderId"],
      amount: (json["amount"] ?? 0).toDouble(),
      dateTime: DateTime.parse(json["dateTime"]),
      status: json["status"] ?? false,
      schemeName: json["scheme"]["scheamName"] ?? "",
    );
  }
}