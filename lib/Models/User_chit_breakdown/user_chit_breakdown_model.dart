class UserChitBreakdownModel {
  final String profileId;
  final int totalChits;
  final double totalChitValue;
  final List<Chit> chits;

  UserChitBreakdownModel({
    required this.profileId,
    required this.totalChits,
    required this.totalChitValue,
    required this.chits,
  });

  factory UserChitBreakdownModel.fromJson(Map<String, dynamic> json) {
    return UserChitBreakdownModel(
      profileId: json['profileId'] ?? '',
      totalChits: json['totalChits'] ?? 0,
      totalChitValue: (json['totalChitValue'] ?? 0).toDouble(),
      chits: (json['chits'] as List<dynamic>?)
          ?.map((e) => Chit.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'totalChits': totalChits,
      'totalChitValue': totalChitValue,
      'chits': chits.map((e) => e.toJson()).toList(),
    };
  }
}

class Chit {
  final String id;
  final String chitsID;
  final String chitsName;
  final String chitsType;
  final double value;
  final double maximumBid;
  final double contribution;
  final String duedate;
  final int totalMember;
  final double miniumBid;
  final int availableSpots;
  final double otherCharges;
  final double penalty;
  final double taxes;
  final int currentMemberCount;
  final int timePeriod;
  final List<AuctionSchedule> auctionSchedules;

  Chit({
    required this.id,
    required this.chitsID,
    required this.chitsName,
    required this.chitsType,
    required this.value,
    required this.maximumBid,
    required this.contribution,
    required this.duedate,
    required this.totalMember,
    required this.miniumBid,
    required this.availableSpots,
    required this.otherCharges,
    required this.penalty,
    required this.taxes,
    required this.currentMemberCount,
    required this.timePeriod,
    required this.auctionSchedules,
  });

  factory Chit.fromJson(Map<String, dynamic> json) {
    return Chit(
      id: json['id'] ?? '',
      chitsID: json['chitsID'] ?? '',
      chitsName: json['chitsName'] ?? '',
      chitsType: json['chitsType'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      maximumBid: (json['maximumBid'] ?? 0).toDouble(),
      contribution: (json['contribution'] ?? 0).toDouble(),
      duedate: json['duedate'] ?? '',
      totalMember: json['totalMember'] ?? 0,
      miniumBid: (json['miniumBid'] ?? 0).toDouble(),
      availableSpots: json['availableSpots'] ?? 0,
      otherCharges: (json['otherCharges'] ?? 0).toDouble(),
      penalty: (json['penalty'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      currentMemberCount: json['currentMemberCount'] ?? 0,
      timePeriod: json['timePeriod'] ?? 0,
      auctionSchedules: (json['auctionSchedules'] as List<dynamic>?)
          ?.map((e) => AuctionSchedule.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chitsID': chitsID,
      'chitsName': chitsName,
      'chitsType': chitsType,
      'value': value,
      'maximumBid': maximumBid,
      'contribution': contribution,
      'duedate': duedate,
      'totalMember': totalMember,
      'miniumBid': miniumBid,
      'availableSpots': availableSpots,
      'otherCharges': otherCharges,
      'penalty': penalty,
      'taxes': taxes,
      'currentMemberCount': currentMemberCount,
      'timePeriod': timePeriod,
      'auctionSchedules': auctionSchedules.map((e) => e.toJson()).toList(),
    };
  }
}

class AuctionSchedule {
  final String id;
  final int auctionNumber;
  final String auctionDate;
  final String dueDate;
  final bool completed;
  final double? winningBid;
  final double? prizeAmount;

  AuctionSchedule({
    required this.id,
    required this.auctionNumber,
    required this.auctionDate,
    required this.dueDate,
    required this.completed,
    this.winningBid,
    this.prizeAmount,
  });

  factory AuctionSchedule.fromJson(Map<String, dynamic> json) {
    return AuctionSchedule(
      id: json['id'] ?? '',
      auctionNumber: json['auctionNumber'] ?? 0,
      auctionDate: json['auctionDate'] ?? '',
      dueDate: json['dueDate'] ?? '',
      completed: json['completed'] ?? false,
      winningBid:
      json['winningBid'] != null ? (json['winningBid'] as num).toDouble() : null,
      prizeAmount:
      json['prizeAmount'] != null ? (json['prizeAmount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auctionNumber': auctionNumber,
      'auctionDate': auctionDate,
      'dueDate': dueDate,
      'completed': completed,
      'winningBid': winningBid,
      'prizeAmount': prizeAmount,
    };
  }
}
