class ChitModel {
  final String id;
  final String chitsID;
  final String chitsName;
  final String chitsType;
  final double value;
  final int timePeriod;
  final int totalMember;
  final double commission;
  final double penalty;
  final double taxes;
  final double otherCharges;
  final DateTime duedate;
  final double contribution;
  final int joined;
  final String winningType;
  final bool isActiveChit;

  ChitModel({
    required this.id,
    required this.chitsID,
    required this.chitsName,
    required this.chitsType,
    required this.value,
    required this.timePeriod,
    required this.totalMember,
    required this.commission,
    required this.penalty,
    required this.taxes,
    required this.otherCharges,
    required this.duedate,
    required this.contribution,
    required this.joined,
    required this.winningType,
    required this.isActiveChit,
  });

  factory ChitModel.fromJson(Map<String, dynamic> json) {
    return ChitModel(
      id: json["id"] ?? "",
      chitsID: json["chitsID"] ?? "",
      chitsName: json["chitsName"] ?? "",
      chitsType: json["chitsType"] ?? "",
      value: (json["value"] ?? 0).toDouble(),
      timePeriod: json["timePeriod"] ?? 0,
      totalMember: json["totalMember"] ?? 0,
      commission: (json["commission"] ?? 0).toDouble(),
      penalty: (json["penalty"] ?? 0).toDouble(),
      taxes: (json["taxes"] ?? 0).toDouble(),
      otherCharges: (json["otherCharges"] ?? 0).toDouble(),
      duedate: DateTime.parse(json["duedate"]),
      contribution: (json["contribution"] ?? 0).toDouble(),
      joined: json["joined"] ?? 0,
      winningType: json["winningType"] ?? "",
      isActiveChit: json["isActiveChit"] ?? false,
    );
  }
}
class ProfileModel {
  final String id;
  final String userID;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final String signupType;
  final bool phoneVerified;
  final bool emailVerified;
  final DateTime joinDate;
  final bool kycVerification;

  ProfileModel({
    required this.id,
    required this.userID,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.signupType,
    required this.phoneVerified,
    required this.emailVerified,
    required this.joinDate,
    required this.kycVerification,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? "",
      userID: json['userID'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      address: json['address'] ?? "",
      gender: json['gender'] ?? "",
      signupType: json['signupType'] ?? "",
      phoneVerified: json['phoneVerified'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      joinDate: DateTime.parse(json['joinDate']),
      kycVerification: json['kycVerification'] ?? false,
    );
  }
}
class ChitReceiptModel {
  final String id;
  final String profileID;
  final String chitID;
  final double amount;
  final String orderId;
  final bool status;
  final DateTime dateTime;

  final ProfileModel profile;
  final ChitModel chit;

  ChitReceiptModel({
    required this.id,
    required this.profileID,
    required this.chitID,
    required this.amount,
    required this.orderId,
    required this.status,
    required this.dateTime,
    required this.profile,
    required this.chit,
  });

  factory ChitReceiptModel.fromJson(Map<String, dynamic> json) {
    return ChitReceiptModel(
      id: json['id'] ?? "",
      profileID: json['profileID'] ?? "",
      chitID: json['chitID'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      orderId: json['orderId'] ?? "",
      status: json['status'] ?? false,
      dateTime: DateTime.parse(json['dateTime']),
      profile: ProfileModel.fromJson(json['profile']),
      chit: ChitModel.fromJson(json['chit']),
    );
  }
}
