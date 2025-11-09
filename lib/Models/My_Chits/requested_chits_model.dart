class RequestedChitModel {
  final String requestId;
  final String chitId;
  final String chitsName;
  final String chitsType;
  final double contribution;
  final DateTime duedate;
  final List<dynamic> members;
  final double miniumBid;
  final double otherCharges;
  final double penalty;
  final double taxes;
  final int currentMemberCount;
  final double value;
  final int timePeriod;
  final String status;
  final DateTime requestDate;

  RequestedChitModel({
    required this.requestId,
    required this.chitId,
    required this.chitsName,
    required this.chitsType,
    required this.contribution,
    required this.duedate,
    required this.members,
    required this.miniumBid,
    required this.otherCharges,
    required this.penalty,
    required this.taxes,
    required this.currentMemberCount,
    required this.value,
    required this.timePeriod,
    required this.status,
    required this.requestDate,
  });

  factory RequestedChitModel.fromJson(Map<String, dynamic> json) {
    return RequestedChitModel(
      requestId: json['requestId'] ?? '',
      chitId: json['chitId'] ?? '',
      chitsName: json['chitsName'] ?? '',
      chitsType: json['chitsType'] ?? '',
      contribution: (json['contribution'] ?? 0).toDouble(),
      duedate: DateTime.parse(json['duedate']),
      members: json['members'] ?? [],
      miniumBid: (json['miniumBid'] ?? 0).toDouble(),
      otherCharges: (json['otherCharges'] ?? 0).toDouble(),
      penalty: (json['penalty'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      currentMemberCount: json['currentMemberCount'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      timePeriod: json['timePeriod'] ?? 0,
      status: json['status'] ?? '',
      requestDate: DateTime.parse(json['requestDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'chitId': chitId,
      'chitsName': chitsName,
      'chitsType': chitsType,
      'contribution': contribution,
      'duedate': duedate.toIso8601String(),
      'members': members,
      'miniumBid': miniumBid,
      'otherCharges': otherCharges,
      'penalty': penalty,
      'taxes': taxes,
      'currentMemberCount': currentMemberCount,
      'value': value,
      'timePeriod': timePeriod,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
    };
  }
}
