import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> populateRooms() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> rooms = [
    {
      'roomType': 'Single Bed Deluxe Room',
      'capacity': 1,
      'availableCapacity': 1,
      'rentPerMonth': 2,
      'roomId': 1,
      'roomNumber': 'A01',  // Added roomNumber field
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2Fselfcontained.jpg?alt=media&token=9b7d0a90-df52-4d28-83c8-6aa0c088984f',
      'amenities': ['WiFi', 'Air Conditioning', 'Private Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': '2-Bed Room Deluxe Room',
      'capacity': 2,
      'availableCapacity': 2,
      'rentPerMonth': 4,
      'roomId': 2,
      'roomNumber': 'B02',  // Added roomNumber field
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F2bed.jpg?alt=media&token=2ab2dcd5-720a-41c0-91e4-300dd73d3c8e',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': '4-Bed Deluxe Room',
      'capacity': 4,
      'availableCapacity': 4,
      'rentPerMonth': 6,
      'roomId': 3,
      'roomNumber': 'C03',  // Added roomNumber field
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2Fselfcontained.jpg?alt=media&token=9b7d0a90-df52-4d28-83c8-6aa0c088984f',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },
    // Add more rooms as needed
  ];

  // Check if the rooms collection already has documents
  QuerySnapshot snapshot = await _firestore.collection('rooms').limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print('Rooms collection already exists. Skipping population.');
    return; // Exit if rooms collection already has documents
  }

  // Populate rooms collection
  for (var room in rooms) {
    await _firestore.collection('rooms').add(room);
  }

  print('Rooms collection populated successfully.');
}
