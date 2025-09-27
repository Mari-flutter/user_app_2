import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
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
            Container(
              width:double.infinity,
              height: 89,
              decoration: BoxDecoration(
                color: Color(0xff322F2F),
                borderRadius: BorderRadius.circular(11)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04,vertical: size.height*0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xff9A9A9A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset('assets/images/Notification/admin.png',width: 11,height: 11,),
                            SizedBox(width: size.width*0.01,),
                            Text(
                              'Admin l 09:00 Pm',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff9A9A9A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      'Reminder: Your chit due is not paid yet. Kindly clear it soon.',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffD7D7D7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
