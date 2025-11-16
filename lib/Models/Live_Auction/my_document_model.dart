class MyDocument {
  final String id; // documentVerificationId
  final String documentTypeId; // actual type id for upload
  final String documentType;
  final String? documentPath;
  final String status;
  final String? uploadedAt;
  final String? verifiedAt;

  MyDocument({
    required this.id,
    required this.documentTypeId,
    required this.documentType,
    this.documentPath,
    required this.status,
    this.uploadedAt,
    this.verifiedAt,
  });

  factory MyDocument.fromJson(Map<String, dynamic> json) {
    return MyDocument(
      id: json['documentVerificationId']?.toString() ?? '',
      documentTypeId: json['documentTypeId']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      documentPath: json['documentPath']?.toString(),
      status: json['status']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString(),
      verifiedAt: json['verifiedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'documentVerificationId': id,
    'documentTypeId': documentTypeId,
    'documentType': documentType,
    'documentPath': documentPath,
    'status': status,
    'uploadedAt': uploadedAt,
    'verifiedAt': verifiedAt,
  };
}
