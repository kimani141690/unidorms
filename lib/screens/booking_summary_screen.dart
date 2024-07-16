import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';
import 'bottom_navigation.dart';
import 'catalogue_screen.dart';
import 'home_screen.dart';
import 'notice_screen.dart';
import '../models/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingSummaryScreen extends StatefulWidget {
  final DocumentSnapshot roomData;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRent;
  final int totalDays;

  BookingSummaryScreen({
    required this.roomData,
    required this.startDate,
    required this.endDate,
    required this.totalRent,
    required this.totalDays,
  });

  @override
  _BookingSummaryScreenState createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final BookingService _bookingService = BookingService();
  int _currentIndex = 1;
  bool _isLoading = false;

  void _proceedToPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Rent: Ksh ${widget.totalRent}'),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.backgroundColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment();
            },
            child: Text('Pay'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    String phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await _bookingService.bookRoom(
        userId: currentUser.uid,
        roomId: widget.roomData.id,
        phoneNumber: phoneNumber,
        amount: widget.totalRent,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      setState(() {
        _isLoading = false;
      });


      Future.delayed(Duration(seconds: 15), () {
        _showSuccessPopup();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error during payment process: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text('Your booking has been confirmed!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      } else if (index == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backlight,
        title: Text('Booking Summary', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.roomData['image'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text('Room Type: ${widget.roomData['roomType']}', style: TextStyle(fontSize: 18)),
            Text('Stay Period: ${widget.startDate} to ${widget.endDate}', style: TextStyle(fontSize: 18)),
            Text('Total Days: ${widget.totalDays}', style: TextStyle(fontSize: 18)),
            Text('Total Rent: Ksh ${widget.totalRent}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20), // Add some space before the buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking process cancelled.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CatalogueScreen()));
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _proceedToPayment,
                    child: Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backlight,
                      foregroundColor: AppColors.textBlack,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Push content above to center the buttons vertically
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
        notificationCount: 3, // Example notification count, adjust as needed
      ),
    );
  }
}
