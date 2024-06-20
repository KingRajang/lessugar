import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add this import statement

class DinnerPage extends StatefulWidget {
  final DateTime selectedDate; // Add the selectedDate parameter
  final Function(double, double) updateTotals;

  DinnerPage({required this.selectedDate, required this.updateTotals});

  @override
  _DinnerPageState createState() => _DinnerPageState();
}

class _DinnerPageState extends State<DinnerPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  double totalBreakfastSugar = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  Future<void> _calculateTotals() async {
    double totalCalories = 0.0;
    double totalSugar = 0.0;

    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('dinner')
        .where('date', isEqualTo: formattedDate)
        .get();

    for (var doc in snapshot.docs) {
      totalCalories += (doc['calories'] ?? 0.0) * doc['count'];
      totalSugar += (doc['sugar'] ?? 0.0) * doc['count'];
    }

    widget.updateTotals(totalCalories, totalSugar);
    setState(() {
      totalBreakfastSugar = totalSugar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              'assets/Breakfast.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Dinner',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 150,
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
                    child: Column(
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
                          '${totalBreakfastSugar.toStringAsFixed(1)} g',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: 16,
            right: 16,
            bottom: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('dinner')
                  .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(widget.selectedDate))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.docs;

                double totalCalories = 0.0;
                double totalSugar = 0.0;

                for (var doc in items) {
                  totalCalories += (doc['calories'] ?? 0.0) * doc['count'];
                  totalSugar += (doc['sugar'] ?? 0.0) * doc['count'];
                }

                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  widget.updateTotals(totalCalories, totalSugar);
                  setState(() {
                    totalBreakfastSugar = totalSugar;
                  });
                });

                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item['food_name']),
                        subtitle: Text('Count: ${item['count']}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
