class CurrentGoldValue {
  final String id;
  final double goldValue;
  final DateTime date;

  CurrentGoldValue({
    required this.id,
    required this.goldValue,
    required this.date,
  });

  factory CurrentGoldValue.fromJson(Map<String, dynamic> json) {
    return CurrentGoldValue(
      id: json['id'] ?? '',
      goldValue: (json['goldValue'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goldValue': goldValue,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CurrentGoldValue(id: $id, goldValue: $goldValue, date: $date)';
  }
}
