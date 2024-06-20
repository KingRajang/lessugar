import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'styles.dart';

class FoodInfoPage extends StatefulWidget {
  final Map<String, dynamic> foodData;

  FoodInfoPage({required this.foodData});

  @override
  _FoodInfoPageState createState() => _FoodInfoPageState();
}

class _FoodInfoPageState extends State<FoodInfoPage> {
  int _count = 1;
  String _selectedMeal = 'Breakfast';
  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addFoodToMeal() async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection(_selectedMeal.toLowerCase())
            .add({
          'food_name': widget.foodData['food_name'],
          'count': _count,
          'calories': widget.foodData['nf_calories'],
          'sugar': widget.foodData['nf_sugars'],
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to $_selectedMeal')),
        );
      } catch (e) {
        print('Error adding food to meal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add food')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.foodData['food_name'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Text('Serving Size: ${widget.foodData['serving_qty']} ${widget.foodData['serving_unit']}'),
            SizedBox(height: 16),
            Text('Calories: ${widget.foodData['nf_calories']} kcal'),
            SizedBox(height: 8),
            Text('Sugar: ${widget.foodData['nf_sugars']} g'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Count: $_count', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_count > 1) _count--;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _count++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Total Calories: ${(_count * widget.foodData['nf_calories']).toStringAsFixed(2)} kcal'),
            SizedBox(height: 8),
            Text('Total Sugar: ${(_count * widget.foodData['nf_sugars']).toStringAsFixed(2)} g'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedMeal,
                  items: _meals.map((String meal) {
                    return DropdownMenuItem<String>(
                      value: meal,
                      child: Text(meal),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMeal = newValue!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _addFoodToMeal,
                  child: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coralColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
