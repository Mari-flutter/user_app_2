class MyDocument {
  final String id;
  final String documentTypeId;
  final String documentType;
  final String? documentPath;
  final String status;
  final String? uploadedAt;
  final String? verifiedAt;
  final List<Approval> approvals; // NEW

  MyDocument({
    required this.id,
    required this.documentTypeId,
    required this.documentType,
    this.documentPath,
    required this.status,
    this.uploadedAt,
    this.verifiedAt,
    required this.approvals, // NEW
  });

  factory MyDocument.fromJson(Map<String, dynamic> json) {
    return MyDocument(
      id: json['id']?.toString() ?? '',
      documentTypeId: json['documentTypeID']?.toString() ?? '',
      documentType: json['documentType']?['name']?.toString() ?? '',
      documentPath: json['documentPath']?.toString(),
      status: json['status']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString(),
      verifiedAt: json['verifiedAt']?.toString(),
      approvals: (json["approvals"] as List? ?? [])
          .map((e) => Approval.fromJson(e))
          .toList(),
    );
  }
}
class Approval {
  final bool isApproved;

  Approval({required this.isApproved});

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      isApproved: json["isApproved"] ?? false,
    );
  }
}

