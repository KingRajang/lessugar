import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcoming_page.dart';
import 'styles.dart';

const int _coralPrimaryValue = 0xFFFF7F50;

const MaterialColor coralColor = MaterialColor(
  _coralPrimaryValue,
  <int, Color>{
    50: Color(0xFFFFE8E1),
    100: Color(0xFFFFC9B3),
    200: Color(0xFFFFA680),
    300: Color(0xFFFF8250),
    400: Color(0xFFFF6633),
    500: Color(_coralPrimaryValue),
    600: Color(0xFFFF6F47),
    700: Color(0xFFFF643D),
    800: Color(0xFFFF5A34),
    900: Color(0xFFFF4724),
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LessugarApp());
}

class LessugarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lessugar',
      theme: ThemeData(
        primarySwatch: coralColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcomingPage();
  }

  _navigateToWelcomingPage() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Landing.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
