import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unidorms/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'login_screen.dart';
import 'bottom_navigation.dart';
import 'profile_screen.dart'; 
import 'catalogue_screen.dart';


class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  HomeScreen({this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (widget.userData != null) {
      userData = widget.userData;
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)));
      } else if (index == 2) {
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8DBAC4),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: userData != null && userData!['profileImage'] != null
                  ? NetworkImage(userData!['profileImage'])
                  : AssetImage('assets/images/userAvatar.jpg') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(
              'Welcome ${userData?['username'] ?? 'User'}',
              style: TextStyle(
                fontSize: 14.0, // Set your desired font size
                color: AppColors.textBlack,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/profile_images%2Fui_images%2Fhomepage.jpg?alt=media&token=5295feeb-c1ae-49cb-99be-ebb402c06950',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                title: Text('My Room'),
                subtitle: Text('4 Bed Deluxe Room\nRoom No. 210\nStatus: Checked In'),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                ServiceCard(
                  imagePath: 'assets/images/catalogue.png',
                  label: 'Catalogue',
                  onTap: () => Navigator.pushNamed(context, '/catalogue'),
                  ),   
                ServiceCard(imagePath: 'assets/images/payment.png', label: 'Payment'),
                ServiceCard(
                  imagePath: 'assets/images/profile.png',
                  label: 'Profile',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userData: userData,
                        onProfileUpdated: (updatedData) {
                          setState(() {
                            userData = updatedData;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                ServiceCard(imagePath: 'assets/images/maintenance.png', label: 'Maintenance'),
                ServiceCard(imagePath: 'assets/images/guest.png', label: 'Guest'),
                ServiceCard(imagePath: 'assets/images/checkin.png', label: 'Check In'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  ServiceCard({required this.imagePath, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFF8DBAC4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                height: 40,
                width: 40,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
