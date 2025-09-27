class VerifyOtpModel {
  final String phoneNumber;
  final String otp;

  VerifyOtpModel({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() {
    return {
      "phoneNumber": phoneNumber,
      "otp": otp,
    };
  }

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      phoneNumber: json['phoneNumber'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  final String message;
  final String token;
  final String profileId;
  final String phoneNumber;
  final bool phoneVerified;

  VerifyOtpResponse({
    required this.message,
    required this.token,
    required this.profileId,
    required this.phoneNumber,
    required this.phoneVerified,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      profileId: json['profileId'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      phoneVerified: json['phoneVerified'] ?? false,
    );
  }
}
