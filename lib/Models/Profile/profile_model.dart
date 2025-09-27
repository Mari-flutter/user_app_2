class Profile {
  final String id;
  final String userID;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final String dateOfBirth;
  final String signupType;
  final bool phoneVerified;
  final bool emailVerified;
  final String joinDate;
  final bool kycVerification;
  final String referBy;

  Profile({
    required this.id,
    required this.userID,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.signupType,
    required this.phoneVerified,
    required this.emailVerified,
    required this.joinDate,
    required this.kycVerification,
    required this.referBy,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      userID: json['userID'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateofBirth'] ?? '',
      signupType: json['signupType'] ?? '',
      phoneVerified: json['phoneVerified'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      joinDate: json['joinDate'] ?? '',
      kycVerification: json['kycVerification'] ?? false,
      referBy: json['referBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'gender': gender,
      'dateofBirth': dateOfBirth,
      'signupType': signupType,
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
      'joinDate': joinDate,
      'kycVerification': kycVerification,
      'referBy': referBy,
    };
  }
}
