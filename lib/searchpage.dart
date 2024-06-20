import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'food_info_page.dart';
import 'styles.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _fetchFoodSuggestions(query);
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  Future<void> _fetchFoodSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await _apiService.searchNutritionix(query);
      setState(() {
        _suggestions = List<Map<String, dynamic>>.from(suggestions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching food data: $e');
    }
  }

  Future<void> _fetchFoodDetailsAndNavigate(String foodId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final foodDetails = await _apiService.getNutritionixFoodDetails(foodId);
      setState(() {
        _isLoading = false;
      });
      _addToSearchHistory(foodDetails['food_name']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodInfoPage(foodData: foodDetails),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching food details: $e');
    }
  }

  void _addToSearchHistory(String foodName) {
    setState(() {
      if (_searchHistory.contains(foodName)) {
        _searchHistory.remove(foodName);
      }
      _searchHistory.insert(0, foodName);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  void _saveSearchHistory() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'searchHistory': _searchHistory,
      }, SetOptions(merge: true));
    }
  }

  void _loadSearchHistory() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _searchHistory = List<String>.from(userDoc['searchHistory'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 24), // Added to push down the back button and title
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Spacer(),
                Text(
                  'Food',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/searchICON.svg',
                    width: 20,
                    height: 20,
                    color: coralColor,
                  ),
                ),
                hintText: 'Search Food...',
                filled: true,
                fillColor: Colors.green[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                children: [
                  if (_searchController.text.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchHistory.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ..._searchHistory.map((food) => ListTile(
                          title: Text(food),
                          onTap: () {
                            _fetchFoodDetailsAndNavigate(food);
                          },
                        )),
                      ],
                    ),
                  if (_searchController.text.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_suggestions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Suggestions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ..._suggestions.map((suggestion) => ListTile(
                          title: Text(suggestion['food_name']),
                          onTap: () {
                            _fetchFoodDetailsAndNavigate(suggestion['food_name']);
                          },
                        )),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
