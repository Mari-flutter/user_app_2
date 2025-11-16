import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

import '../Models/Notification/notification_model.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}
Future<List<UserNotification>> fetchNotifications() async {
  final Token = await SecureStorageService.getToken();
  final ProfileId = await SecureStorageService.getProfileId();
  final url = Uri.parse(
      "https://foxlchits.com/api/Notification/user/$ProfileId");

  final response = await http.get(url,headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer $Token",
  },);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data.map((e) => UserNotification.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load notifications");
  }
}

class _notificationState extends State<notification> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyleGrey = GoogleFonts.urbanist(
      textStyle: TextStyle(color: Color(0xff9A9A9A), fontSize: 12),
    );

    final textStyleWhite = GoogleFonts.urbanist(
      textStyle: TextStyle(color: Color(0xffFFFFFF), fontSize: 14, fontWeight: FontWeight.w600),
    );

    final textStyleLight = GoogleFonts.urbanist(
      textStyle: TextStyle(color: Color(0xffD7D7D7), fontSize: 12),
    );

    String formatDate(String date) {
      final dt = DateTime.parse(date);
      return "${dt.day}-${dt.month}-${dt.year}";
    }

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child:Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xff282828),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeLayout()),
                          );
                        },
                        child: Image.asset(
                          'assets/images/Home_Page_User_Chits_Breakdown/back.png',
                          width: 15,
                          height: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Notifications',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.035),

              // 🔹 Dynamic Notification List
              Expanded(
                child: FutureBuilder<List<UserNotification>>(
                  future: fetchNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return shimmerNotification(size);
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Notifications",
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    final notifications = snapshot.data!;

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Color(0xff322F2F),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDate(n.createdAt),
                                    style: textStyleGrey,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/Notification/admin.png',
                                        width: 11,
                                        height: 11,
                                      ),
                                      SizedBox(width: 5),
                                      Text("Admin", style: textStyleGrey),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(n.title, style: textStyleWhite),
                              SizedBox(height: 4),
                              Text(n.body, style: textStyleLight),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
  Widget shimmerNotification(Size size) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        );
      },
    );
  }

}
