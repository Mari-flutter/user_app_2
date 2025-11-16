class GoldSchemeDueModel {
  final String schemeName;
  final String nextDueDate;
  final int duration;
  final double contribution;
  final double totalPaid;

  GoldSchemeDueModel({
    required this.schemeName,
    required this.nextDueDate,
    required this.duration,
    required this.contribution,
    required this.totalPaid,
  });

  factory GoldSchemeDueModel.fromJson(Map<String, dynamic> json) {
    return GoldSchemeDueModel(
      schemeName: json["schemeName"] ?? "",
      nextDueDate: json["nextDueDate"] ?? "",
      duration: json["duration"] ?? 0,
      contribution: (json["contribution"] ?? 0).toDouble(),
      totalPaid: (json["totalPaid"] ?? 0).toDouble(),
    );
  }
}
