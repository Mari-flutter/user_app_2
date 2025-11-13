class PendingPayment {
  final String chitId;
  final String chitName;
  final String memberId;
  final String profileId;
  final String userId;
  final int month;
  final double totalAmount;
  final double amountPaid;
  final double pendingAmount;
  final DateTime dueDate;
  final DateTime paymentDate;
  final bool isLate;

  PendingPayment({
    required this.chitId,
    required this.chitName,
    required this.memberId,
    required this.profileId,
    required this.userId,
    required this.month,
    required this.totalAmount,
    required this.amountPaid,
    required this.pendingAmount,
    required this.dueDate,
    required this.paymentDate,
    required this.isLate,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      chitId: json["chitId"] ?? '',
      chitName: json["chitName"] ?? '',
      memberId: json["memberId"] ?? '',
      profileId: json["profileId"] ?? '',
      userId: json["userId"] ?? '',
      month: json["month"] ?? 0,
      totalAmount: (json["totalAmount"] ?? 0).toDouble(),
      amountPaid: (json["amountPaid"] ?? 0).toDouble(),
      pendingAmount: (json["pendingAmount"] ?? 0).toDouble(),
      dueDate: DateTime.tryParse(json["dueDate"] ?? '') ?? DateTime.now(),
      paymentDate: DateTime.tryParse(json["paymentDate"] ?? '') ?? DateTime.now(),
      isLate: json["isLate"] ?? false,
    );
  }
}
