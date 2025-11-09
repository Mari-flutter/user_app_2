import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/confirm_your_booking_screen.dart';
import 'package:user_app/Investments/Gold/get_physical_gold_screen.dart';

class store_selection extends StatefulWidget {
  const store_selection({super.key});

  @override
  State<store_selection> createState() => _store_selectionState();
}

class _store_selectionState extends State<store_selection> {
  final List<String> stores_tag = ['Coimbatore', 'Chennai', 'Madurai', 'Erode'];
  final List<Map<String, String>> stores = [
    {
      'address': '45, MG Road, Bangalore - 560001',
      'time': '10:00 AM - 9:00 PM',
      'contact': '+91 80 2558 4400',
      'conversionCharge': '2% + GST',
      'logoPath': 'assets/images/Investments/malabar.png',
    },
    {
      'address': '12, Brigade Road, Bangalore - 560025',
      'time': '10:30 AM - 8:30 PM',
      'contact': '+91 80 2555 1234',
      'conversionCharge': '1.8% + GST',
      'logoPath': 'assets/images/Investments/tanishq.png',
    },
    {
      'address': 'No.22, Jayanagar, Bangalore - 560041',
      'time': '10:00 AM - 9:00 PM',
      'contact': '+91 80 2564 7890',
      'conversionCharge': '2.5% + GST',
      'logoPath': 'assets/images/Investments/jos.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => get_physical_gold(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Store Selection',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextField(
                    style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: Color(0xffFFFFFF),
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xff1F1F1F),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff61512B)),
                        borderRadius: BorderRadius.circular(11),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xff61512B),
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff61512B)),
                        borderRadius: BorderRadius.circular(11),
                      ),

                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff61512B),
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),

                      hintText: 'Search Store Location',
                      hintStyle: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff5C5C5C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        // reduces icon area size
                        child: GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            'assets/images/Investments/search_store.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(stores_tag.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == stores_tag.length - 1
                              ? 0
                              : size.width * 0.035,
                        ),
                        child: Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(0xff282828),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              stores_tag[index],
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  'Showing stores in Banglore',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffC5C5C5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    return
                    Padding(
                      padding:EdgeInsets.only(bottom:20),
                      child: Container(
                        width: double.infinity,
                        height: 154,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(0xff1F1F1F),
                          border: Border.all(
                            color: Color(0xff61512B),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.01,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/Investments/malabar.png',
                                    width: 58,
                                    height: 42,
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Malabar Gold and Diamonds',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffC5AE6D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '45, MG Road, Bangalore - 560001',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffDDDDDD),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  SizedBox(width: size.width * 0.04),
                                  Image.asset(
                                    'assets/images/Investments/store_open_timing.png',
                                    width: 9,
                                    height: 9,
                                  ),
                                  Text(
                                    ' 10:00 AM-9:00 PM  ',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/Investments/store_contact.png',
                                    width: 9,
                                    height: 9,
                                  ),
                                  Text(
                                    '  +91 80 2558 4400',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  SizedBox(width: size.width * 0.04),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Conversion Charge',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffDDDDDD),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '2% + GST',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff898989),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>confirm_your_booking()));
                                    },
                                    child: Container(
                                      width: 83,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Color(0xff61512B),
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Confirm Store',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDDDDDD),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
