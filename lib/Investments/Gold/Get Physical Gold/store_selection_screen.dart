import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // <-- Import HTTP package
import 'dart:convert'; // <-- Import dart:convert for JSON decoding

import '../../../Helper/Local_storage_manager.dart';
import '../../../Models/Investments/Gold/store_model.dart';
import 'confirm_your_booking_screen.dart';

class store_selection extends StatefulWidget {
  final double selectedGrams;
  final EstimateValue;
  const store_selection({super.key, required this.selectedGrams, required this.EstimateValue});

  @override
  State<store_selection> createState() => _store_selectionState();
}

class _store_selectionState extends State<store_selection> {
  // Store the full list of stores fetched from the API
  List<StoreSelectionModel> _allStores = [];
  // Store the list of stores currently displayed (filtered or full list)
  List<StoreSelectionModel> _displayedStores = [];


  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  bool _isLoading = true; // State to manage loading indicator

  // --- API Endpoint and Base URL for Assets ---
  final String _apiUrl = 'https://foxlchits.com/api/SchemeMember/all';
  // Use the API's domain as the base URL for images
  static const String _ASSET_BASE_URL = 'https://foxlchits.com/';


  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    // Add listener to search controller for real-time filtering
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // =======================================================
  // 1. API Fetching Logic (Inline)
  // =======================================================
  Future<List<StoreSelectionModel>> _fetchSchemeMembers() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => StoreSelectionModel.fromJson(json)).toList();
    } else {
      // Throw an exception to be caught in _fetchStoreData
      throw Exception('Failed to load scheme members. Status: ${response.statusCode}');
    }
  }

  // --- Main Data Loading Function ---
  Future<void> _fetchStoreData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Try to load from cache first
      List<StoreSelectionModel> cachedStores = LocalStorageManager.getStoreSelections();

      if (cachedStores.isNotEmpty) {
        setState(() {
          _allStores = cachedStores;
          _displayedStores = cachedStores;
        });
        print('Loaded stores from cache.');
      }

      // 2. Fetch from API
      List<StoreSelectionModel> apiStores = await _fetchSchemeMembers();

      if (mounted && apiStores.isNotEmpty) {
        // Only update if the data is different or if cache was empty
        if (_allStores.length != apiStores.length || cachedStores.isEmpty) {
          await LocalStorageManager.saveStoreSelections(apiStores);
          setState(() {
            _allStores = apiStores;
            // Re-apply filter in case we were searching
            _filterStores(_currentSearchQuery);
          });
          print('Loaded stores from API and updated cache.');
        }
      }

    } catch (e) {
      print('Error fetching store data: $e');
      // Set empty list and stop loading if an error occurs
      if (mounted) {
        setState(() {
          _allStores = [];
          _displayedStores = [];
        });
      }
      // TODO: Show a user-friendly error message (e.g., Snackbar)
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // =======================================================
  // 2. Search/Filter Logic
  // =======================================================
  void _onSearchChanged() {
    final query = _searchController.text;
    if (_currentSearchQuery != query) {
      setState(() {
        _currentSearchQuery = query;
      });
      _filterStores(query);
    }
  }

  void _filterStores(String query) {
    if (query.isEmpty) {
      setState(() {
        _displayedStores = _allStores;
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();

    // Filter based on shopName or address
    final filteredList = _allStores.where((store) {
      final shopNameMatch = store.shopName.toLowerCase().contains(lowerCaseQuery);
      final addressMatch = store.address.toLowerCase().contains(lowerCaseQuery);
      return shopNameMatch || addressMatch;
    }).toList();

    setState(() {
      _displayedStores = filteredList;
    });
  }

  // Helper function to build the full image URL
  String _buildFullImageUrl(String relativePath) {
    // Prevent double slashes if the path already starts with one (although usually the API path shouldn't)
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    // Remove leading slash from relativePath if it exists, then combine
    final cleanedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '$_ASSET_BASE_URL$cleanedPath';
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                // --- HEADER ---
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Use pop to go back to the previous screen
                        Navigator.pop(context);
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
                // --- SEARCH FIELD ---
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextField(
                    style: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xffFFFFFF),
                    controller: _searchController,
                    onSubmitted: _filterStores, // Filter on 'Enter'
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xff1F1F1F),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      // ... (Your border styling) ...
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xff61512B)),
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
                        borderSide: const BorderSide(color: Color(0xff61512B)),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xff61512B),
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      // ... (End of border styling) ...
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
                        child: GestureDetector(
                          onTap: () {
                            _filterStores(_searchController.text);
                          },
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
                // --- Display Count ---
                Text(
                  _currentSearchQuery.isNotEmpty
                      ? 'Showing ${_displayedStores.length} results for "$_currentSearchQuery"'
                      : 'Showing ${_displayedStores.length} stores',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffC5C5C5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                // --- LIST VIEW / LOADING INDICATOR ---
                _isLoading
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height * 0.1),
                    child: const CircularProgressIndicator(
                      color: Color(0xffC5AE6D),
                    ),
                  ),
                )
                    : _displayedStores.isEmpty
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height * 0.1),
                    child: Text(
                      _currentSearchQuery.isNotEmpty
                          ? 'No stores found for "$_currentSearchQuery"'
                          : 'No stores available. Please try again later.',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffC5C5C5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _displayedStores.length,
                  itemBuilder: (context, index) {
                    final store = _displayedStores[index];
                    final fullImageUrl = _buildFullImageUrl(store.logo);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: double.infinity,
                        height: 154,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: const Color(0xff1F1F1F),
                          border: Border.all(
                            color: const Color(0xff61512B),
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
                                  // --- DYNAMIC LOGO/IMAGE (Network) ---
                                  ClipOval( // <-- WRAP WITH ClipOval
                                    child: Image.network(
                                      fullImageUrl, // <-- Uses the constructed full URL
                                      width: 58,    // Set fixed dimensions for the circle
                                      height: 58,   // Set fixed dimensions for the circle
                                      fit: BoxFit.cover, // Ensures the image fills the circle without distortion
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to a local asset on error
                                        return Image.asset(
                                          'assets/images/Investments/malabar.png', // Placeholder
                                          width: 58,
                                          height: 58, // Adjusted height to match circle width
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          width: 58,
                                          height: 42,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffC5AE6D)),
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store.shopName, // Bind shopName
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffC5AE6D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        store.address, // Bind address
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
                              // --- CONTACT DETAILS ---
                              Row(
                                children: [
                                  SizedBox(width: size.width * 0.04),
                                  Image.asset(
                                    'assets/images/Investments/store_open_timing.png',
                                    width: 9,
                                    height: 9,
                                  ),
                                  const Text(
                                    ' 10:00 AM-7:00 PM  ',
                                    style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/Investments/store_contact.png',
                                    width: 9,
                                    height: 9,
                                  ),
                                  Text(
                                    '  ${store.phoneNumber}', // Bind phoneNumber
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
                              // --- Confirm Button ---
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => confirm_your_booking(
                                          selectedStore: store, // Pass the selected model
                                          selectedGrams: widget.selectedGrams,
                                          EstimatedValue:widget.EstimateValue,
                                          Storecontact:store.phoneNumber,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 83,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff61512B),
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