class RealEstateTxModel {
  final String id;
  final String paymentId;
  final String orderId;
  final double amount;
  final String dateTime;
  final bool status;

  RealEstateTxModel({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.dateTime,
    required this.status,
  });

  factory RealEstateTxModel.fromJson(Map<String, dynamic> json) {
    return RealEstateTxModel(
      id: json["id"],
      paymentId: json["paymentID"],
      orderId: json["orderId"],
      amount: (json["amount"] as num).toDouble(),
      dateTime: json["dateTime"],
      status: json["status"],
    );
  }
}
