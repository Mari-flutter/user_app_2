import 'dart:convert';

List<ActiveChit> activeChitFromJson(String str) =>
    List<ActiveChit>.from(json.decode(str).map((x) => ActiveChit.fromJson(x)));

String activeChitToJson(List<ActiveChit> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActiveChit {
  final String id;
  final String chitsName;
  final String chitsType;
  final double value;
  final double maximumBid;
  final double contribution;
  final DateTime duedate;
  final List<Member> members;
  final double miniumBid;
  final double otherCharges;
  final double penalty;
  final double taxes;
  final int totalMember;
  final int availableSpots;
  final int currentMemberCount;
  final int timePeriod;

  ActiveChit({
    required this.id,
    required this.chitsName,
    required this.chitsType,
    required this.value,
    required this.maximumBid,
    required this.contribution,
    required this.duedate,
    required this.members,
    required this.miniumBid,
    required this.otherCharges,
    required this.penalty,
    required this.taxes,
    required this.totalMember,
    required this.availableSpots,
    required this.currentMemberCount,
    required this.timePeriod,
  });

  factory ActiveChit.fromJson(Map<String, dynamic> json) => ActiveChit(
    id: json["id"],
    chitsName: json["chitsName"],
    chitsType: json["chitsType"],
    value: (json["value"] ?? 0).toDouble(),
    maximumBid: (json["maximumBid"] ?? 0).toDouble(),
    contribution: (json["contribution"] ?? 0).toDouble(),
    duedate: DateTime.parse(json["duedate"]),
    members: List<Member>.from(
        (json["members"] ?? []).map((x) => Member.fromJson(x))),
    miniumBid: (json["miniumBid"] ?? 0).toDouble(),
    otherCharges: (json["otherCharges"] ?? 0).toDouble(),
    penalty: (json["penalty"] ?? 0).toDouble(),
    taxes: (json["taxes"] ?? 0).toDouble(),
    totalMember: json["totalMember"] ?? 0,
    availableSpots: json["availableSpots"] ?? 0,
    currentMemberCount: json["currentMemberCount"] ?? 0,
    timePeriod: json["timePeriod"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chitsName": chitsName,
    "chitsType": chitsType,
    "value": value,
    "maximumBid": maximumBid,
    "contribution": contribution,
    "duedate": duedate.toIso8601String(),
    "members": List<dynamic>.from(members.map((x) => x.toJson())),
    "miniumBid": miniumBid,
    "otherCharges": otherCharges,
    "penalty": penalty,
    "taxes": taxes,
    "totalMember": totalMember,
    "availableSpots": availableSpots,
    "currentMemberCount": currentMemberCount,
    "timePeriod": timePeriod,
  };
}

class Member {
  final String id;
  final String chitId;
  final String profileId;
  final dynamic profile;
  final String userID;
  final DateTime joinDate;
  final bool paid;
  final double howMuchtopay;
  final bool chitTaken;
  final DateTime? chitTakenDate;
  final double? amountTaken;
  final bool isActive;

  Member({
    required this.id,
    required this.chitId,
    required this.profileId,
    this.profile,
    required this.userID,
    required this.joinDate,
    required this.paid,
    required this.howMuchtopay,
    required this.chitTaken,
    this.chitTakenDate,
    this.amountTaken,
    required this.isActive,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json["id"],
    chitId: json["chitId"],
    profileId: json["profileId"],
    profile: json["profile"],
    userID: json["userID"],
    joinDate: DateTime.parse(json["joinDate"]),
    paid: json["paid"],
    howMuchtopay: (json["howMuchtopay"] ?? 0).toDouble(),
    chitTaken: json["chitTaken"],
    chitTakenDate: json["chitTakenDate"] != null
        ? DateTime.parse(json["chitTakenDate"])
        : null,
    amountTaken: json["amountTaken"] != null
        ? (json["amountTaken"] as num).toDouble()
        : null,
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chitId": chitId,
    "profileId": profileId,
    "profile": profile,
    "userID": userID,
    "joinDate": joinDate.toIso8601String(),
    "paid": paid,
    "howMuchtopay": howMuchtopay,
    "chitTaken": chitTaken,
    "chitTakenDate":
    chitTakenDate != null ? chitTakenDate!.toIso8601String() : null,
    "amountTaken": amountTaken,
    "isActive": isActive,
  };
}
