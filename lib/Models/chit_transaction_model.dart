class ChitTransactionModel {
  final String chitName;
  final String amount;
  final String date;
  final bool status;

  ChitTransactionModel({
    required this.chitName,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory ChitTransactionModel.fromJson(Map<String, dynamic> json) {
    return ChitTransactionModel(
      chitName: json['chitName'] ?? '',
      amount: json['amount'].toString(),
      date: json['dateTime']?.split("T")[0] ?? "",
      status: json['status'] ?? true,   // true = debited
    );
  }
}
