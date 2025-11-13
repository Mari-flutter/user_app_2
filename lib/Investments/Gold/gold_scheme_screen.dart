import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/My_Investments/my_investments_screen.dart';
import 'package:user_app/widgets/noise_background_container.dart';

import '../../Helper/Local_storage_manager.dart';
import '../../Models/Investments/Gold/gold_scheme_model.dart';
import '../../Services/secure_storage.dart';

class gold_scheme extends StatefulWidget {
  const gold_scheme({super.key});

  @override
  State<gold_scheme> createState() => _gold_schemeState();
}

class _gold_schemeState extends State<gold_scheme> {
  List<GoldScheme> goldSchemes = [];
  Set<String> subscribingSchemeIds = {};
  bool isSubscribing = false;

  @override
  void initState() {
    super.initState();
    loadFromCacheThenFetch();
  }

  // 🧠 Load cached + background fetch
  Future<void> loadFromCacheThenFetch() async {
    final cachedSchemes = LocalStorageManager.getGoldSchemes();
    if (cachedSchemes.isNotEmpty) {
      setState(() => goldSchemes = cachedSchemes);
    }
    fetchGoldSchemesInBackground();
  }

  // 🔄 Fetch from API silently
  Future<void> fetchGoldSchemesInBackground() async {
    try {
      final response = await http.get(
        Uri.parse('https://foxlchits.com/api/GoldScheme'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedSchemes = data.map((e) => GoldScheme.fromJson(e)).toList();

        bool isDifferent = _isListDifferent(fetchedSchemes, goldSchemes);

        if (isDifferent) {
          print('🔄 Gold scheme data changed — updating cache & UI');
          await LocalStorageManager.saveGoldSchemes(fetchedSchemes);
          if (mounted) setState(() => goldSchemes = fetchedSchemes);
        } else {
          print('✅ Gold scheme data already up to date');
        }
      } else {
        print('⚠️ Failed to fetch gold schemes: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching gold schemes: $e');
    }
  }

  bool _isListDifferent(List<GoldScheme> newList, List<GoldScheme> oldList) {
    if (newList.length != oldList.length) return true;
    for (int i = 0; i < newList.length; i++) {
      if (jsonEncode(newList[i].toJson()) != jsonEncode(oldList[i].toJson())) {
        return true;
      }
    }
    return false;
  }

  // 🪄 Subscribe API call
  Future<void> subscribeToScheme(String schemeId) async {
    // Variable to hold the error message we want to display
    String errorMessage = 'Subscription failed. Please try again.';

    try {
      final profileId = await SecureStorageService.getProfileId();

      if (profileId == null || profileId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not found. Please login again.')),
        );
        return;
      }

      // START LOADING: Add the specific schemeId to the set
      setState(() => subscribingSchemeIds.add(schemeId));

      final url = Uri.parse(
        'https://foxlchits.com/api/SchemeMember/join?schemeId=$schemeId&profileId=$profileId',
      );

      print('📡 Subscribing: $url');

      final response = await http.post(url);

      // STOP LOADING (SUCCESS/FAILURE): Remove the specific schemeId from the set
      if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- SUCCESS BLOCK ---
        print('✅ Subscription successful for Scheme: $schemeId');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully subscribed to the scheme!')),
        );

        // 🟢 Navigate to My Investments
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const my_investments(initialTab: 0),
          ),
        );
      } else {
        // --- FAILURE BLOCK (Status Code != 200/201) ---
        print('⚠️ Subscription failed: ${response.statusCode}');

        // 🔑 Attempt to extract custom error message from the response body
        try {
          if (response.body.isNotEmpty) {
            final errorJson = jsonDecode(response.body);

            // This part is HIGHLY dependent on your API's error structure.
            // Common keys are 'message', 'error', 'title', or sometimes the raw JSON string is the error.
            if (errorJson is Map && errorJson.containsKey('message')) {
              errorMessage = errorJson['message']?.toString() ?? errorMessage;
            } else if (errorJson is Map && errorJson.containsKey('error')) {
              errorMessage = errorJson['error']?.toString() ?? errorMessage;
            } else if (response.body.length < 200) { // If it's a small, non-JSON body, use it directly
              errorMessage = response.body;
            }
          }
        } catch (e) {
          // If JSON decoding fails, we stick to the default message or the status code
          print('Error parsing error response body: $e');
          errorMessage = 'Server error (${response.statusCode}).';
        }

        if (!mounted) return;

        // 🔑 SHOW THE CUSTOM/EXTRACTED ERROR MESSAGE
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // --- CATCH BLOCK (Network/Parsing Error) ---
      print('❌ Error subscribing: $e');

      // STOP LOADING (ERROR)
      if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));

      // Handle generic errors (like no internet)
      errorMessage = 'A network error occurred. Check your connection.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/Investments/gold_scheme.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: size.width * 0.02),
            Text(
              'Schemes',
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        goldSchemes.isEmpty
            ? Center(
                child: Text(
                  'No gold schemes available',
                  style: GoogleFonts.urbanist(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: List.generate(goldSchemes.length, (index) {
                    final scheme = goldSchemes[index];
                    final isCurrentSchemeLoading = subscribingSchemeIds.contains(scheme.id);
                    return Padding(
                      padding: EdgeInsets.only(bottom: size.width * 0.05),
                      child: NoiseBackgroundContainer(
                        height: 145,
                        // same height as before
                        dotSize: 0.5,
                        // set 1.0 for visible dots; reduce if too strong
                        density: 1,
                        // tweak: smaller = more dots; larger = fewer dots
                        opacity: 0.15,
                        // 15% opacity
                        color: Colors.white,
                        child: Container(
                          width: double.infinity,
                          height: 145,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                              vertical: size.height * 0.015,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${scheme.duration} Month Plan',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${scheme.contribution.toStringAsFixed(0)}/month',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffDBDBDB),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Value',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDBDBDB),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${scheme.totalValue.toStringAsFixed(0)}',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffF8C545),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: size.width * 0.05),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Est. Gold',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDBDBDB),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${scheme.estimateValue.toStringAsFixed(0)}',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffF8C545),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (isCurrentSchemeLoading) return;
                                      await subscribeToScheme(scheme.id);
                                    },
                                    child: Container(
                                      width: 89,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xffF8C545),
                                            Color(0xff8F7021),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child:isCurrentSchemeLoading
                                            ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                            :  Text(
                                          'Subscribe',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
      ],
    );
  }
}
