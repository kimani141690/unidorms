import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../colors.dart';
import 'dates_screen.dart';

class RoomDetailsScreen extends StatefulWidget {
  final DocumentSnapshot roomData;

  const RoomDetailsScreen({Key? key, required this.roomData}) : super(key: key);

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late Map<String, dynamic> roomData;
  bool isLoading = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    roomData = widget.roomData.data() as Map<String, dynamic>;
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<bool> _hasExistingReservationOrBooking() async {
    final userReservation = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: currentUser?.uid)
        .get();

    return userReservation.docs.isNotEmpty;
  }

  Future<void> _preBookRoom() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (await _hasExistingReservationOrBooking()) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already have a reserved or booked room.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      String reservationId = Uuid().v4();

      await FirebaseFirestore.instance.collection('reservations').doc(reservationId).set({
        'userId': currentUser?.uid,
        'roomId': widget.roomData.id,
        'status': 'reserved',
        'timestamp': FieldValue.serverTimestamp(),
        'expiryTime': DateTime.now().add(Duration(minutes: 2)),
      });

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomData.id)
          .update({
        'status': 'reserved',
        'availableCapacity': FieldValue.increment(-1),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': currentUser?.uid,
        'message': 'You have reserved room ${roomData['roomType']} no. ${roomData['roomId']}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        roomData['status'] = 'reserved';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room reserved successfully.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Schedule cancellation of reservation after 2 minutes
      Future.delayed(Duration(minutes: 2), () async {
        final reservation = await FirebaseFirestore.instance
            .collection('reservations')
            .doc(reservationId)
            .get();

        if (reservation.exists && reservation.data()?['status'] == 'reserved') {
          await FirebaseFirestore.instance.collection('reservations').doc(reservationId).delete();

          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomData.id)
              .update({
            'status': 'available',
            'availableCapacity': FieldValue.increment(1),
          });

          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': currentUser?.uid,
            'message': 'Your reservation for room ${roomData['roomType']} no. ${roomData['roomId']} has been cancelled due to time expiry.',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reserve the room. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _bookRoom() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (await _hasExistingReservationOrBooking()) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already have a reserved or booked room.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DatesScreen(roomData: widget.roomData),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to proceed with booking. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backlight,
        title: Text('Room', style: TextStyle(color: AppColors.textBlack)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${roomData['roomType']} no. ${roomData['roomId']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CachedNetworkImage(
              imageUrl: roomData['image'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Card(
              color: AppColors.backlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bed: Double Decker', style: TextStyle(fontSize: 16)),
                    Text('Occupants: ${roomData['capacity']}', style: TextStyle(fontSize: 16)),
                    Text('Amenities: Self-contained toilet and bathroom', style: TextStyle(fontSize: 16)),
                    Text('Price: Ksh ${roomData['rentPerMonth']}', style: TextStyle(fontSize: 16)),
                    Text('Cost Model: per person sharing', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _preBookRoom,
                  child: Text('Pre-Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backlight,
                    foregroundColor: AppColors.textBlack,
                    minimumSize: Size(150, 50),
                  ),
                ),
                ElevatedButton(
                  onPressed: _bookRoom,
                  child: Text('Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backlight,
                    foregroundColor: AppColors.textBlack,
                    minimumSize: Size(150, 50),
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
