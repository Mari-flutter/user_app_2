class UserNotification {
  final String id;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;

  UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      createdAt: json['createdAt'],
      isRead: json['isRead'],
    );
  }
}
