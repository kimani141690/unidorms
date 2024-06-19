import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';
import 'home_screen.dart';
import '../models/mpesa_service.dart'; // Import your Mpesa service

class DatesScreen extends StatefulWidget {
  final DocumentSnapshot roomData;

  DatesScreen({required this.roomData});

  @override
  _DatesScreenState createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final TextEditingController _phoneNumberController = TextEditingController();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedStartDate == null || (_selectedStartDate != null && _selectedEndDate != null)) {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      } else if (selectedDay.isBefore(_selectedStartDate!)) {
        _selectedStartDate = selectedDay;
      } else {
        _selectedEndDate = selectedDay;
      }
    });

    // Calculate total rent and proceed to payment
    if (_selectedStartDate != null && _selectedEndDate != null) {
      _calculateAndProceedToPayment();
    }
  }

  void _calculateAndProceedToPayment() {
    int totalDays = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    double totalRent = (totalDays / 30) * widget.roomData['rentPerMonth'];

    _proceedToPayment(totalRent);
  }

  void _proceedToPayment(double totalRent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Rent: Ksh $totalRent'),
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
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(totalRent);
            },
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount) {
    String phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isNotEmpty) {
      MpesaService().initiatePayment(phoneNumber, amount).then((_) {
        _updateRoomCapacity();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateRoomCapacity() async {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(widget.roomData.reference);
      int updatedCapacity = freshSnap['availableCapacity'] - 1;
      transaction.update(widget.roomData.reference, {'availableCapacity': updatedCapacity});
    }).then((_) {
      _showSuccessPopup();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking room. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backlight,
        title: Text('Choose your stay Period', style: TextStyle(color: AppColors.textBlack)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedStartDate ?? DateTime.now(),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              if (_selectedStartDate != null && _selectedEndDate != null) {
                return day.isAfter(_selectedStartDate!.subtract(Duration(days: 1))) &&
                    day.isBefore(_selectedEndDate!.add(Duration(days: 1)));
              } else if (_selectedStartDate != null) {
                return isSameDay(day, _selectedStartDate);
              }
              return false;
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedStartDate != null && _selectedEndDate != null ? () => _calculateAndProceedToPayment() : null,
              child: Text('Proceed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backlight,
                foregroundColor: AppColors.textBlack,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
