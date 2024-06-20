import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'welcoming_page.dart';
import 'styles.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String userName = 'MikeOxmaull';
  String profileImageUrl = '';
  File? _profileImage;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userName = userDoc['name'];
        profileImageUrl = userDoc['profileImageUrl'] ?? '';
      });
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': userName,
        'profileImageUrl': profileImageUrl,
      }, SetOptions(merge: true));
    }
  }



  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String filePath = 'profile_images/${user.uid}.png';
        UploadTask uploadTask = _storage.ref().child(filePath).putFile(_profileImage!);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          profileImageUrl = downloadUrl;
        });

        await _saveUserProfile();

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image uploaded successfully')),
        );

        Navigator.pop(context, profileImageUrl); // Return the new URL to Dashboard
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile image')),
        );
      }
    }
  }




  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditNameDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    nameController.text = userName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  userName = nameController.text;
                });
                _saveUserProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomingPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details, VoidCallback action) {
    _controller.reverse().then((_) {
      action();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              'assets/ProfilePage.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Column(
            children: [
              SizedBox(height: 60),  // Adjusted to bring the circle higher
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('assets/profile_image.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: (details) => _onTapUp(details, _pickImage),
                      onTapCancel: _onTapCancel,
                      child: ScaleTransition(
                        scale: _animation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset(
                              'assets/EditProfileICON.svg',
                              width: 24,
                              height: 24,
                              color: coralColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTapDown: _onTapDown,
                    onTapUp: (details) => _onTapUp(details, () => _showEditNameDialog(context)),
                    onTapCancel: _onTapCancel,
                    child: ScaleTransition(
                      scale: _animation,
                      child: SvgPicture.asset(
                        'assets/EditNameICON.svg',
                        width: 24,
                        height: 24,
                        color: coralColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: (details) => _onTapUp(details, () => _showLogoutConfirmationDialog(context)),
                onTapCancel: _onTapCancel,
                child: ScaleTransition(
                  scale: _animation,
                  child: SvgPicture.asset(
                    'assets/LogOut.svg',
                    width: 48,
                    height: 48,
                    color: coralColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
