import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Future<void> _preBookRoom() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if the user already has a reserved or booked room
      final userReservation = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: currentUser?.uid)
          .get();

      if (userReservation.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already have a reserved or booked room.'),
          ),
        );
        return;
      }

      // Reserve the room for the user
      await FirebaseFirestore.instance.collection('reservations').add({
        'userId': currentUser?.uid,
        'roomId': widget.roomData.id,
        'status': 'reserved',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the room status to reserved
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomData.id)
          .update({'status': 'reserved'});

      setState(() {
        roomData['status'] = 'reserved';
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room reserved successfully.'),
        ),
      );

      Navigator.of(context).pop(); // Redirect back to the catalogue page
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reserve the room. Please try again.'),
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
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DatesScreen(roomData: widget.roomData),
                    ));
                  },
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
