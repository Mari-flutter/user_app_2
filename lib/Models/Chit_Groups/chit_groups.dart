import 'dart:convert';

/// Represents a single chit item from the ChitsCreate/all API.
class Chit_Group_Model {
  final String id;
  final String chitsID;
  final String chitsName;
  final String chitsType;
  final double value;
  final int timePeriod;
  final int totalMember;
  final double miniumBid;
  final double maximumBid;
  final double contribution;
  final double commission;
  final double penalty;
  final double taxes;
  final double otherCharges;
  final String winningType;
  final DateTime duedate;
  final List<DateTime> auctionDates;

  Chit_Group_Model({
    required this.id,
    required this.chitsID,
    required this.chitsName,
    required this.chitsType,
    required this.value,
    required this.timePeriod,
    required this.totalMember,
    required this.miniumBid,
    required this.maximumBid,
    required this.contribution,
    required this.commission,
    required this.penalty,
    required this.taxes,
    required this.otherCharges,
    required this.winningType,
    required this.duedate,
    required this.auctionDates,
  });

  /// Create a ChitModel instance from a JSON map.
  factory Chit_Group_Model.fromJson(Map<String, dynamic> json) {
    return Chit_Group_Model(
      id: json['id'] ?? '',
      chitsID: json['chitsID'] ?? '',
      chitsName: json['chitsName'] ?? '',
      chitsType: json['chitsType'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      timePeriod: json['timePeriod'] ?? 0,
      totalMember: json['totalMember'] ?? 0,
      miniumBid: (json['miniumBid'] ?? 0).toDouble(),
      maximumBid: (json['maximumBid'] ?? 0).toDouble(),
      contribution: (json['contribution'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      penalty: (json['penalty'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      otherCharges: (json['otherCharges'] ?? 0).toDouble(),
      winningType: json['winningType'] ?? '',
      duedate: DateTime.tryParse(json['duedate'] ?? '') ?? DateTime.now(),
      auctionDates:
          (json['auctionDates'] as List<dynamic>?)
              ?.map((e) => DateTime.tryParse(e.toString()) ?? DateTime.now())
              .toList() ??
          [],
    );
  }

  /// Convert a ChitModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chitsID': chitsID,
      'chitsName': chitsName,
      'chitsType': chitsType,
      'value': value,
      'timePeriod': timePeriod,
      'totalMember': totalMember,
      'miniumBid': miniumBid,
      'maximumBid': maximumBid,
      'contribution': contribution,
      'commission': commission,
      'penalty': penalty,
      'taxes': taxes,
      'otherCharges': otherCharges,
      'winningType': winningType,
      'duedate': duedate.toIso8601String(),
      'auctionDates': auctionDates.map((e) => e.toIso8601String()).toList(),
    };
  }

  /// Parse a list of ChitModel objects from a JSON string.
  static List<Chit_Group_Model> listFromJson(String responseBody) {
    final List<dynamic> jsonData = json.decode(responseBody);
    return jsonData.map((e) => Chit_Group_Model.fromJson(e)).toList();
  }
}
