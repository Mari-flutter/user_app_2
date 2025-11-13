class GoldScheme {
  final String id;
  final String scheamName;
  final double totalValue;
  final int duration;
  final double contribution;
  final String dueDate;
  final double estimateValue;
  final double charges;

  GoldScheme({
    required this.id,
    required this.scheamName,
    required this.totalValue,
    required this.duration,
    required this.contribution,
    required this.dueDate,
    required this.estimateValue,
    required this.charges,
  });

  factory GoldScheme.fromJson(Map<String, dynamic> json) {
    return GoldScheme(
      id: json['id'] ?? '',
      scheamName: json['scheamName'] ?? '',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      contribution: (json['contribution'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
      estimateValue: (json['estimateValue'] ?? 0).toDouble(),
      charges: (json['charges'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheamName': scheamName,
      'totalValue': totalValue,
      'duration': duration,
      'contribution': contribution,
      'dueDate': dueDate,
      'estimateValue': estimateValue,
      'charges': charges,
    };
  }
}
