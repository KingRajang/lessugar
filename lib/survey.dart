// survey.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard.dart';
import 'styles.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final String _welcomeText = "Welcome!";
  String _displayedText = "";
  bool _showSurvey = false;
  bool _showSugarIntakeField = false; // To control the visibility of the sugar intake field

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sugarIntakeController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';
  final List<String> _activityLevels = ['Sedentary', 'Lightly active', 'Moderately active', 'Very active', 'Super active'];

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    int index = 0;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (index < _welcomeText.length) {
        setState(() {
          _displayedText += _welcomeText[index];
          index++;
        });
      } else {
        timer.cancel();
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _showSurvey = true;
          });
        });
      }
    });
  }

  double _sugarLimit = 0.0;
  void _calculateSugarIntake() {
    double weight = double.parse(_weightController.text);
    double height = double.parse(_heightController.text);

    double bmr = 10 * weight + 6.25 * height - 5 * 25; // Simplified BMR calculation for a 25-year-old
    double activityFactor;

    switch (_selectedActivityLevel) {
      case 'Sedentary':
        activityFactor = 1.2;
        break;
      case 'Lightly active':
        activityFactor = 1.375;
        break;
      case 'Moderately active':
        activityFactor = 1.55;
        break;
      case 'Very active':
        activityFactor = 1.725;
        break;
      case 'Super active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    double dailyCalories = bmr * activityFactor;
    double dailySugarLimit = dailyCalories * 0.1 / 4; // Assuming 10% of daily calories from sugar and 1g sugar = 4 calories

    setState(() {
      _sugarIntakeController.text = dailySugarLimit.toStringAsFixed(2);
      _showSugarIntakeField = true; // Show the sugar intake field after calculation
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Daily Sugar Intake'),
          content: Text('Your recommended daily sugar intake is ${dailySugarLimit.toStringAsFixed(2)} grams.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: coralColor,
      body: Center(
        child: _showSurvey ? _buildSurvey() : _buildWelcomeText(),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _displayedText,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSurvey() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Let's Set Your Sugar Limit",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _heightController,
            decoration: InputDecoration(
              labelText: 'Height (cm)',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedActivityLevel,
            items: _activityLevels.map((String activity) {
              return DropdownMenuItem<String>(
                value: activity,
                child: Text(activity),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedActivityLevel = newValue!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Activity Level',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _calculateSugarIntake,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: coralColor,
            ),
            child: Text('Calculate'),
          ),
          SizedBox(height: 20),
          if (_showSugarIntakeField) // Conditionally show the sugar intake field
            Column(
              children: [
                TextField(
                  controller: _sugarIntakeController,
                  decoration: InputDecoration(
                    labelText: 'Daily Sugar Intake (grams)',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                // After calculation and user confirmation
                ElevatedButton(
                  onPressed: () {
                    double sugarLimit = double.tryParse(_sugarIntakeController.text) ?? 100.0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dashboard(initialSugarLimit: sugarLimit),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: coralColor,
                  ),
                  child: Text('Confirm'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
