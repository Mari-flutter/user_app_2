class ProfileUpdateResponse {
  final String message;
  final ProfileUpdate profile;

  ProfileUpdateResponse({
    required this.message,
    required this.profile,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message'] ?? '',
      profile: ProfileUpdate.fromJson(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'profile': profile.toJson(),
    };
  }
}

class ProfileUpdate {
  final String name;
  final String email;
  final String address;
  final String gender;
  final String dateOfBirth;

  ProfileUpdate({
    required this.name,
    required this.email,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
  });

  factory ProfileUpdate.fromJson(Map<String, dynamic> json) {
    return ProfileUpdate(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateofBirth'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'gender': gender,
      'dateofBirth': dateOfBirth,
    };
  }
}
