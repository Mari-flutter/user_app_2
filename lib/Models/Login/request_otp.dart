class RequestOtpModel {
  final String phoneNumber;

  RequestOtpModel({required this.phoneNumber});

  // Convert Dart object → JSON (for sending to API)
  Map<String, dynamic> toJson() {
    return {"phoneNumber": phoneNumber};
  }

  // Optional: Parse response (if API returns any data)
  factory RequestOtpModel.fromJson(Map<String, dynamic> json) {
    return RequestOtpModel(phoneNumber: json['phoneNumber'] ?? '');
  }
}
