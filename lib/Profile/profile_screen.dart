import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_app/Profile/kyc_verified.dart';
import 'package:http/http.dart' as http;

import '../Helper/Local_storage_manager.dart';
import '../Live_Auction/Attach_files/attach_file_screen.dart';
import '../Models/Live_Auction/my_document_model.dart';
import '../Models/Profile/profile_model.dart';
import '../Models/Profile/profile_update_model.dart' hide Profile;
import '../Services/secure_storage.dart';
import 'package:path/path.dart' as path;

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  bool _isLoading = true;
  List<MyDocument> _documents = [];
  bool isEdited = false;
  bool isExpanded = false;
  Image? selected_Image;
  String? selectedValue;
  DateTime? _selectedDate;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool _isPrefilled = false;

  TextEditingController Phonenumbercontroller = TextEditingController();
  final mobileController = TextEditingController();

  final storage = FlutterSecureStorage();
  String? profileId; // store the loaded ID
  Future<Profile>? profileFuture; // nullable

  @override
  void initState() {
    super.initState();
    _loadProfileId();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //get data
  Future<Profile> getProfileData() async {
    final response = await http.get(
      Uri.parse("https://foxlchits.com/api/Profile/profile/${profileId}"),
    );
    print(profileId);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  //put data
  Future<void> updateProfile(ProfileUpdate profile) async {
    final url = Uri.parse("https://foxlchits.com/api/Profile/${profileId}");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      print("✅ Profile updated successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } else {
      print("❌ Failed to update profile: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update profile")));
    }
  }

  Future<void> _loadProfileId() async {
    profileId = await storage.read(key: 'profileId');
    if (profileId != null && profileId!.isNotEmpty) {
      // Load cached profile if available
      final cachedProfile = LocalStorageManager.getProfile(profileId!);
      if (cachedProfile != null) {
        _setControllers(cachedProfile);
        profileFuture = Future.value(cachedProfile);
      } else {
        profileFuture = getProfileData();
      }

      // Fetch fresh data in background
      getProfileData().then((freshProfile) async {
        await LocalStorageManager.saveProfile(freshProfile, profileId!);
        if (!mounted) return;
        _setControllers(freshProfile); // update UI
      });
      _fetchDocumentsFromServer();
      setState(() {}); // refresh FutureBuilder after initial assignment
    } else {
      print("⚠️ No profileId found");
    }
  }

  void _setControllers(Profile profile) {
    if (!_isPrefilled) {
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phoneNumber;
      addressController.text = profile.address;
      selectedValue = profile.gender;

      if (_selectedDate == null && profile.dateOfBirth.isNotEmpty) {
        try {
          final parts = profile.dateOfBirth.split('-'); // MM-DD-YYYY
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        } catch (_) {
          _selectedDate = null;
        }
      }
      _isPrefilled = true;
    }
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "";
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  Future<void> _fetchDocumentsFromServer() async {
    try {
      final profileId = await SecureStorageService.getProfileId();
      if (profileId == null) {
        print("⚠️ No profileId found in SecureStorage");
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse(
        "https://foxlchits.com/api/Auctionwinner/my-documents/$profileId",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _documents = data.map((e) => MyDocument.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        print("❌ Failed to fetch documents: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("⚠️ Error fetching documents: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewFile(MyDocument doc) async {
    if (doc.documentPath != null && doc.documentPath!.isNotEmpty) {
      try {
        final url = "https://foxlchits.com${doc.documentPath}";
        final uri = Uri.parse(url);

        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();

          // ✅ Extract file name and extension safely
          String fileName = path.basename(uri.path); // e.g., "aadhar.jpg"
          if (!fileName.contains('.')) {
            // fallback if no extension present
            fileName = "${doc.documentType}.pdf";
          }

          final file = File("${dir.path}/$fileName");
          await file.writeAsBytes(response.bodyBytes);

          // ✅ Open any file type (image, pdf, doc, etc.)
          await OpenFilex.open(file.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to download file.")),
          );
        }
      } catch (e) {
        print("⚠️ View file error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error opening file.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No file uploaded for ${doc.documentType}")),
      );
    }
  }

  Future<void> _pulltorefersh() async {
    getProfileData();
    _fetchDocumentsFromServer();
  }

  Widget verifiedTick(bool isVerified) {
    return isVerified
        ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16)
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2563EB), // dark black shade on top
              Color(0xFF000000), // smooth middle
              Color(0xFF000000),
              Color(0xFF000000), // smooth middle
              Color(0xFF000000),
              Color(0xFF000000), // smooth middle
              Color(0xFF000000), // slightly lighter bottom
            ],
          ),
        ),
        child: profileFuture == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder(
                future: profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No profile data found'));
                  }

                  if (snapshot.hasData) {
                    final profile = snapshot.data!;
                    if (!_isPrefilled) {
                      nameController.text = profile.name;
                      emailController.text = profile.email;
                      phoneController.text = profile.phoneNumber;
                      addressController.text = profile.address;
                      selectedValue = profile.gender;
                      _isPrefilled = true; // avoid reassigning
                    }

                    if (_selectedDate == null &&
                        profile.dateOfBirth.isNotEmpty) {
                      try {
                        final parts = profile.dateOfBirth.split(
                          '-',
                        ); // MM-DD-YYYY
                        _selectedDate = DateTime(
                          int.parse(parts[2]), // year
                          int.parse(parts[0]), // month
                          int.parse(parts[1]), // day
                        );
                      } catch (e) {
                        _selectedDate = null;
                        print("Failed to parse DOB: $e");
                      }
                    }

                    selectedValue ??= profile.gender;

                    return SafeArea(
                      child: RefreshIndicator(
                        onRefresh: _pulltorefersh,
                        displacement: 40,
                        color: Colors.white,
                        backgroundColor: const Color(0xff3A7AFF),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.04),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SupportText(
                                      text: 'Profile',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: appclr.profile_clr1,
                                      fontType: FontType.urbanist,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (isEdited) {
                                          // Currently in edit mode, now user clicked Save → trigger update
                                          final updatedProfile = ProfileUpdate(
                                            name: nameController.text.isEmpty
                                                ? profile.name
                                                : nameController.text,
                                            email: emailController.text.isEmpty
                                                ? profile.email
                                                : emailController.text,
                                            address:
                                                addressController.text.isEmpty
                                                ? profile.address
                                                : addressController.text,
                                            gender:
                                                selectedValue ?? profile.gender,
                                            dateOfBirth: _selectedDate != null
                                                ? "${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}"
                                                : profile.dateOfBirth,
                                          );

                                          await updateProfile(updatedProfile);
                                        }

                                        setState(() {
                                          isEdited = !isEdited;
                                        });
                                      },

                                      child: SupportText(
                                        text: isEdited ? 'Save' : 'Edit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isEdited
                                            ? Color(0xff3A7AFF)
                                            : appclr.profile_clr1,
                                        fontType: FontType.urbanist,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.04),
                                Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Color(0xff0C204C),
                                      border: Border.all(
                                        color: Color(0xff0E1629),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: SupportText(
                                        text: '${getInitials(profile.name)}',
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xffFFFFFF),
                                        fontType: FontType.urbanist,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.04),
                                const SupportText(
                                  text: 'Name',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.015),
                                inputTextField(
                                  '${profile.name}',
                                  nameController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return "This field cannot be empty";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: size.height * 0.02),
                                const SupportText(
                                  text: 'User Id / Referal Id',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.015),
                                inputTextField(
                                  '${profile.userID}',
                                  TextEditingController(),
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return "This field cannot be empty";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SupportText(
                                      text: 'Date of Birth',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: appclr.profile_clr2,
                                      fontType: FontType.urbanist,
                                    ),
                                    SizedBox(width: size.width * 0.26),
                                    const SupportText(
                                      text: 'Gender',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: appclr.profile_clr2,
                                      fontType: FontType.urbanist,
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.015),
                                calendarandgender(
                                  profile.dateOfBirth,
                                  profile.gender,
                                ),
                                SizedBox(height: size.height * 0.02),
                                const SupportText(
                                  text: 'Mobile Number',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.015),
                                Row(
                                  children: [
                                    Expanded(
                                      child: mobileTextField(
                                        profile.phoneNumber,
                                        suffixIcon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.greenAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),
                                SupportText(


                                  text: 'Mail ID',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.015),
                                inputTextField(
                                  '${profile.email}',
                                  emailController,
                                  (value) {},
                                  suffixIcon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                const SupportText(
                                  text: 'Address',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.015),
                                inputTextField(
                                  '${profile.address}',
                                  addressController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return "This field cannot be empty";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: size.height * 0.02),
                                SupportText(
                                  text: 'Upload Documents',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: appclr.profile_clr2,
                                  fontType: FontType.urbanist,
                                ),
                                SizedBox(height: size.height * 0.02),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _documents.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio:
                                            3.5, // makes height smaller
                                      ),
                                  itemBuilder: (context, index) {
                                    final doc = _documents[index];
                                    final bool hasFile =
                                        doc.documentPath != null &&
                                        doc.documentPath!.isNotEmpty;
                                    final bool isVerified =
                                        doc.verifiedAt != null &&
                                        doc.verifiedAt!.isNotEmpty;

                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xff323232),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(11),
                                        color: Colors.black,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Document Type Name
                                          Expanded(
                                            child: SupportText(
                                              text: doc.documentType,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: appclr.profile_clr2,
                                              fontType: FontType.urbanist,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          // Icons (✅ and add/view)
                                          Row(
                                            children: [
                                              // 🧾 Show view icon if document exists, else add icon
                                              GestureDetector(
                                                onTap: hasFile
                                                    ? () => _viewFile(doc)
                                                    : () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                attach_file(),
                                                          ),
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Add document for ${doc.documentType}",
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 6,
                                                      ),
                                                  child: Image.asset(
                                                    hasFile
                                                        ? 'assets/images/Live_Auction/view_document.png'
                                                        : 'assets/images/Live_Auction/add_document.png',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              // ✅ Show verified tick
                                              if (isVerified)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.greenAccent,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                        ],
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
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
    );
  }

  inputTextField(
    String hintText,
    TextEditingController controller,
    String? Function(String?) validator, {
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      readOnly: !isEdited,
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: TextInputType.text,
      style: GoogleFonts.urbanist(
        color: Color(0xffADADAD), // your desired color
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.017,
        ),
        filled: true,
        fillColor: Colors.black,
        hintText: hintText,
        hintStyle: GoogleFonts.urbanist(
          color: Color(0xffADADAD),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFF323232), // Added border color
            width: 1.0,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFF323232), // Border color when not focused
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF323232), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color.fromARGB(220, 166, 42, 42),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  calendarandgender(String dob, String gender) {
    Size size = MediaQuery.of(context).size;
    String? dropdownValue;

    if (selectedValue == "Male" || selectedValue == "Female") {
      dropdownValue = selectedValue;
    } else if (gender.toLowerCase() == "male") {
      dropdownValue = "Male";
    } else if (gender.toLowerCase() == "female") {
      dropdownValue = "Female";
    } else {
      dropdownValue = null;
    }

    return Column(
      children: [
        Row(
          children: [
            // Date Picker
            Expanded(
              child: GestureDetector(
                onTap: isEdited ? () => _pickDate(context) : null,
                child: Container(
                  height: size.height * 0.06,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff323232), width: 1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SupportText(
                          text: _selectedDate == null
                              ? (dob.isEmpty ? 'Select Date' : dob)
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appclr.profile_clr1,
                          fontType: FontType.urbanist,
                        ),
                      ),
                      if (isEdited)
                        Image.asset(
                          'assets/images/Profile/calender.png',
                          height: size.height * 0.03,
                          width: size.width * 0.06,
                          color: appclr.profile_clr2,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: size.width * 0.04),

            // Gender Dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: isEdited
                        ? () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          }
                        : null, // ✅ only allow toggle if isEdited
                    child: Container(
                      height: size.height * 0.06,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff323232), width: 1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SupportText(
                              text: selectedValue ?? "Select Gender",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: appclr.profile_clr1,
                              fontType: FontType.urbanist,
                            ),
                          ),
                          if (isEdited)
                            Image.asset(
                              isExpanded
                                  ? 'assets/images/Profile/gender_up.png'
                                  : 'assets/images/Profile/gender_down.png',
                              height: size.height * 0.03,
                              width: size.width * 0.06,
                              color: appclr.profile_clr2,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isExpanded && isEdited)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: size.width * 0.45,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xff141414),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Color(0xff323232), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selected_Image = Image.asset(
                          'assets/images/Profile/male.png',
                          width: 16,
                          height: 16,
                        );
                        selectedValue = "Male";
                        isExpanded = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/Profile/male.png',
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(width: size.width * 0.03),
                          const Text(
                            "Male",
                            style: TextStyle(
                              color: Color(0xffADADAD),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selected_Image = Image.asset(
                          'assets/images/Profile/female.png',
                          width: 16,
                          height: 16,
                        );
                        selectedValue = "Female";
                        isExpanded = false;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/Profile/female.png',
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(width: size.width * 0.03),
                          const Text(
                            "Female",
                            style: TextStyle(
                              color: Color(0xffADADAD),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget mobileTextField(String phoneNumber, {Widget? suffixIcon}) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff323232)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: TextFormField(
        readOnly: !isEdited,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.017,
          ),
          hintText: phoneNumber.isEmpty ? "Enter phone number" : phoneNumber,
          hintStyle: GoogleFonts.urbanist(
            color: Color(0xffADADAD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  loginbutton() {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => kyc_verified()),
        );
      },
      child: Container(
        height: 38,
        width: 162,
        decoration: BoxDecoration(
          color: Color(0xff2563EB).withOpacity(.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: SupportText(
            text: 'Proceed with KYC',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: appclr.profile_clr1,
            fontType: FontType.urbanist,
          ),
        ),
      ),
    );
  }
}

enum FontType { urbanist }

class SupportText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final FontType fontType;
  final VoidCallback? onTap;

  const SupportText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    required this.fontType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;

    switch (fontType) {
      case FontType.urbanist:
        style = GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

class appclr {
  static const Color profile_clr1 = Color(0xffFFFFFF);
  static const Color profile_clr2 = Color(0xffADADAD);
  static const Color bg = Colors.black;
  static const Color blue = Color(0xff2563EB);
  static const Color dblue = Color(0xff1088FF);
  static const Color lightpink = Color(0xffCAB4B4);
  static const Color lightgrey = Color(0xff737373);
}
