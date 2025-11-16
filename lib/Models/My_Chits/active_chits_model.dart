import 'dart:convert';

List<ActiveChit> activeChitFromJson(String str) =>
    List<ActiveChit>.from(json.decode(str).map((x) => ActiveChit.fromJson(x)));

String activeChitToJson(List<ActiveChit> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// --- 1. ACTIVE CHIT MODEL ---
class ActiveChit {
  final String id;
  final String chitsID;
  final String chitsName;
  final String chitsType;
  final double value;
  final double maximumBid;
  final double contribution;
  final DateTime duedate;
  // This is the model the compiler was looking for
  final List<AuctionSchedule> auctionSchedules;
  final double miniumBid;
  final double otherCharges;
  final double penalty;
  final double taxes;
  final double commission;
  final int totalMember;
  final int availableSpots;
  final int timePeriod;

  // Calculated Field
  int get currentMemberCount {
    return totalMember - availableSpots;
  }

  ActiveChit({
    required this.id,
    required this.chitsID,
    required this.chitsName,
    required this.chitsType,
    required this.value,
    required this.maximumBid,
    required this.contribution,
    required this.duedate,
    required this.auctionSchedules,
    required this.miniumBid,
    required this.otherCharges,
    required this.penalty,
    required this.taxes,
    required this.commission,
    required this.totalMember,
    required this.availableSpots,
    required this.timePeriod,
  });

  factory ActiveChit.fromJson(Map<String, dynamic> json) => ActiveChit(
    id: json["id"],
    chitsID: json["chitsID"] ?? '',
    chitsName: json["chitsName"],
    chitsType: json["chitsType"],
    value: (json["value"] ?? 0).toDouble(),
    maximumBid: (json["maximumBid"] ?? 0).toDouble(),
    contribution: (json["contribution"] ?? 0).toDouble(),
    duedate: DateTime.parse(json["duedate"]),
    auctionSchedules: List<AuctionSchedule>.from(
        (json["auctionSchedules"] ?? []).map((x) => AuctionSchedule.fromJson(x))),
    miniumBid: (json["miniumBid"] ?? 0).toDouble(),
    otherCharges: (json["otherCharges"] ?? 0).toDouble(),
    penalty: (json["penalty"] ?? 0).toDouble(),
    taxes: (json["taxes"] ?? 0).toDouble(),
    commission: (json["commission"]??0).toDouble(),
    totalMember: json["totalMember"] ?? 0,
    availableSpots: json["availableSpots"] ?? 0,
    timePeriod: json["timePeriod"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chitsID": chitsID,
    "chitsName": chitsName,
    "chitsType": chitsType,
    "value": value,
    "maximumBid": maximumBid,
    "contribution": contribution,
    "duedate": duedate.toIso8601String(),
    "auctionSchedules": List<dynamic>.from(auctionSchedules.map((x) => x.toJson())),
    "miniumBid": miniumBid,
    "otherCharges": otherCharges,
    "penalty": penalty,
    "taxes": taxes,
    "commission":commission,
    "totalMember": totalMember,
    "availableSpots": availableSpots,
    "timePeriod": timePeriod,
  };
}


// --- 2. AUCTION SCHEDULE MODEL (The missing piece) ---
class AuctionSchedule {
  final String id;
  final int auctionNumber;
  final DateTime auctionDate;
  final DateTime dueDate;
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

  factory AuctionSchedule.fromJson(Map<String, dynamic> json) => AuctionSchedule(
    id: json["id"],
    auctionNumber: json["auctionNumber"] ?? 0,
    auctionDate: DateTime.parse(json["auctionDate"]),
    dueDate: DateTime.parse(json["dueDate"]),
    completed: json["completed"] ?? false,
    winningBid: json["winningBid"] != null ? (json["winningBid"] as num).toDouble() : null,
    prizeAmount: json["prizeAmount"] != null ? (json["prizeAmount"] as num).toDouble() : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "auctionNumber": auctionNumber,
    "auctionDate": auctionDate.toIso8601String(),
    "dueDate": dueDate.toIso8601String(),
    "completed": completed,
    "winningBid": winningBid,
    "prizeAmount": prizeAmount,
  };
}