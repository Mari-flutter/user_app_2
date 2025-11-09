import 'dart:convert';

List<ExploreChit> exploreChitFromJson(String str) =>
    List<ExploreChit>.from(
      json.decode(str).map((x) => ExploreChit.fromJson(x)),
    );

String exploreChitToJson(List<ExploreChit> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExploreChit {
  final String memberId;
  final String userId;
  final int action;
  final double amountPaid;
  final double howMuchToPay;
  final bool paid;
  final DateTime paymentDate;
  final DateTime dueDate;
  final bool isLate;

  ExploreChit({
    required this.memberId,
    required this.userId,
    required this.action,
    required this.amountPaid,
    required this.howMuchToPay,
    required this.paid,
    required this.paymentDate,
    required this.dueDate,
    required this.isLate,
  });

  factory ExploreChit.fromJson(Map<String, dynamic> json) => ExploreChit(
    memberId: json["memberId"],
    userId: json["userId"],
    action: json["action"],
    amountPaid: (json["amountPaid"] ?? 0).toDouble(),
    howMuchToPay: (json["howMuchToPay"] ?? 0).toDouble(),
    paid: json["paid"] ?? false,
    paymentDate: DateTime.parse(json["paymentDate"]),
    dueDate: DateTime.parse(json["dueDate"]),
    isLate: json["isLate"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "memberId": memberId,
    "userId": userId,
    "action": action,
    "amountPaid": amountPaid,
    "howMuchToPay": howMuchToPay,
    "paid": paid,
    "paymentDate": paymentDate.toIso8601String(),
    "dueDate": dueDate.toIso8601String(),
    "isLate": isLate,
  };
}
