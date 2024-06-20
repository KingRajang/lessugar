import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'breakfast.dart';
import 'lunch.dart';
import 'dinner.dart';
import 'snacks.dart';
import 'searchpage.dart';
import 'profile.dart';
import 'package:intl/intl.dart';
import 'styles.dart';

class Dashboard extends StatefulWidget {
  final double initialSugarLimit;

  Dashboard({this.initialSugarLimit = 100.0});

  @override
  _DashboardState createState() => _DashboardState();
}


class _DashboardState extends State<Dashboard> {

  String _gradeTotalSugarIntake(double totalSugarIntake) {
    double percentage = totalSugarIntake / sugarLimit * 100;
    if (percentage <= 20) {
      return 'A';
    } else if (percentage <= 40) {
      return 'B';
    } else if (percentage <= 60) {
      return 'C';
    } else if (percentage <= 80) {
      return 'D';
    } else {
      return 'E';
    }
  }


  bool _showGrade = false;

  void _toggleDisplay() {
    setState(() {
      _showGrade = !_showGrade;
    });
  }

  late double sugarLimit;

  final User? user = FirebaseAuth.instance.currentUser;
  DateTime _selectedDate = DateTime.now();

  String profileImageUrl = '';

  double totalBreakfastCalories = 0.0;
  double totalBreakfastSugar = 0.0;

  double totalLunchCalories = 0.0;
  double totalLunchSugar = 0.0;

  double totalDinnerCalories = 0.0;
  double totalDinnerSugar = 0.0;

  double totalSnacksCalories = 0.0;
  double totalSnacksSugar = 0.0;

  @override
  void initState() {
    super.initState();
    sugarLimit = widget.initialSugarLimit > 0 ? widget.initialSugarLimit : 100.0; // Ensure it's not zero
    _fetchDataForDate(_selectedDate);
    _fetchProfileImageUrl(); // Fetch initial profile image URL
  }

  bool showGrade = false;

  void _toggleView() {
    setState(() {
      showGrade = !showGrade;
    });
  }


  void _fetchProfileImageUrl() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          profileImageUrl = doc.data()!['profileImageUrl'] ?? '';
        });
      }
    }
  }

  void _updateTotals() {
    setState(() {});
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _fetchDataForDate(_selectedDate);
    });
  }

  Future<void> _fetchDataForDate(DateTime date) async {
    // Reset totals
    setState(() {
      totalBreakfastCalories = 0.0;
      totalBreakfastSugar = 0.0;
      totalLunchCalories = 0.0;
      totalLunchSugar = 0.0;
      totalDinnerCalories = 0.0;
      totalDinnerSugar = 0.0;
      totalSnacksCalories = 0.0;
      totalSnacksSugar = 0.0;
    });

    // Fetch data for the selected date
    if (user != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      await _fetchMealData('breakfast', formattedDate, _updateBreakfastTotals);
      await _fetchMealData('lunch', formattedDate, _updateLunchTotals);
      await _fetchMealData('dinner', formattedDate, _updateDinnerTotals);
      await _fetchMealData('snacks', formattedDate, _updateSnacksTotals);

      // Update the totals after fetching data for all meals
      _updateTotals();
    }
  }



  Future<void> _fetchMealData(String meal, String date, Function(double, double) updateTotals) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection(meal)
        .where('date', isEqualTo: date)
        .get();

    double totalCalories = 0.0;
    double totalSugar = 0.0;

    for (var doc in snapshot.docs) {
      totalCalories += (doc['calories'] ?? 0.0) * doc['count'];
      totalSugar += (doc['sugar'] ?? 0.0) * doc['count'];
    }

    updateTotals(totalCalories, totalSugar);
  }

  void _updateBreakfastTotals(double totalCalories, double totalSugar) {
    setState(() {
      totalBreakfastCalories = totalCalories;
      totalBreakfastSugar = totalSugar;
    });
  }

  void _updateLunchTotals(double totalCalories, double totalSugar) {
    setState(() {
      totalLunchCalories = totalCalories;
      totalLunchSugar = totalSugar;
    });
  }

  void _updateDinnerTotals(double totalCalories, double totalSugar) {
    setState(() {
      totalDinnerCalories = totalCalories;
      totalDinnerSugar = totalSugar;
    });
  }

  void _updateSnacksTotals(double totalCalories, double totalSugar) {
    setState(() {
      totalSnacksCalories = totalCalories;
      totalSnacksSugar = totalSugar;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalSugarIntake = totalBreakfastSugar + totalLunchSugar + totalDinnerSugar + totalSnacksSugar;
    double progress = totalSugarIntake / sugarLimit;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              'assets/Dashboard.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/profile_image.png') as ImageProvider,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => _changeDate(-1),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 16,
            right: 16,
            child: _buildSugarCircularProgressBar(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: 16,
            child: Text(
              'Daily,',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.08, // Space for the navbar
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCard(context, 'Breakfast', totalBreakfastCalories, totalBreakfastSugar),
                  _buildCard(context, 'Lunch', totalLunchCalories, totalLunchSugar),
                  _buildCard(context, 'Dinner', totalDinnerCalories, totalDinnerSugar),
                  _buildCard(context, 'Snacks', totalSnacksCalories, totalSnacksSugar),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/DashboardICON.svg',
                      color: coralColor,
                      width: 24, // Smaller icon size
                      height: 24, // Smaller icon size
                    ),
                    onPressed: () {
                      // Handle dashboard icon press
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/scannerICON.svg',
                      color: coralColor,
                      width: 24, // Smaller icon size
                      height: 24, // Smaller icon size
                    ),
                    onPressed: () {
                      // Handle scanner icon press
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugarCircularProgressBar() {
    double totalSugarIntake = totalBreakfastSugar + totalLunchSugar + totalDinnerSugar + totalSnacksSugar;
    double progress = totalSugarIntake / sugarLimit;
    bool isOverLimit = totalSugarIntake > sugarLimit;
    String grade = _gradeTotalSugarIntake(totalSugarIntake);

    return Center(
      child: GestureDetector(
        onTap: _toggleDisplay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 15,
                valueColor: AlwaysStoppedAnimation<Color>(isOverLimit ? Colors.red : coralColor),
                backgroundColor: Colors.grey[300],
              ),
            ),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: _showGrade
                    ? Text(
                  grade,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sugar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalSugarIntake.toStringAsFixed(1)}/$sugarLimit g',
                      style: TextStyle(
                        fontSize: 16,
                        color: isOverLimit ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String meal, double kcal, double sugar) {
    return GestureDetector(
      onTap: () {
        switch (meal) {
          case 'Breakfast':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BreakfastPage(
                  selectedDate: _selectedDate, // Pass the selected date
                  updateTotals: (totalCalories, totalSugar) {
                    setState(() {
                      totalBreakfastCalories = totalCalories;
                      totalBreakfastSugar = totalSugar;
                    });
                  },
                ),
              ),
            );
            break;
          case 'Lunch':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LunchPage(
                  selectedDate: _selectedDate, // Pass the selected date
                  updateTotals: (totalCalories, totalSugar) {
                    setState(() {
                      totalLunchCalories = totalCalories;
                      totalLunchSugar = totalSugar;
                    });
                  },
                ),
              ),
            );
            break;
          case 'Dinner':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DinnerPage(
                  selectedDate: _selectedDate, // Pass the selected date
                  updateTotals: (totalCalories, totalSugar) {
                    setState(() {
                      totalDinnerCalories = totalCalories;
                      totalDinnerSugar = totalSugar;
                    });
                  },
                ),
              ),
            );
            break;
          case 'Snacks':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SnacksPage(
                  selectedDate: _selectedDate, // Pass the selected date
                  updateTotals: (totalCalories, totalSugar) {
                    setState(() {
                      totalSnacksCalories = totalCalories;
                      totalSnacksSugar = totalSugar;
                    });
                  },
                ),
              ),
            );
            break;
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$kcal Kcal'),
                      Text('$sugar g'),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: coralColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

