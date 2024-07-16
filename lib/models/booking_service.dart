import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'mpesa_service.dart';
import 'package:logger/logger.dart';



class BookingService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final MpesaService _mpesaService = MpesaService();

  Future<void> bookRoom({
    required String userId,
    required String roomId,
    required String phoneNumber,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Check if the room has available capacity
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Room document does not exist.');
      }

      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      int availableCapacity = roomData['availableCapacity'];
      if (availableCapacity <= 0) {
        throw Exception('No available capacity');
      }

      // Create a new booking document with a pending status
      DocumentReference bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId,
        'roomId': roomId,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'pending', // Initial status
      });

      String bookingId = bookingRef.id;

      // Initiate Mpesa payment
      await _mpesaService.initiatePayment(phoneNumber, amount, bookingId);

      // Store payment data in payments collection
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': userId,
        'bookingId': bookingId,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the booking document with status paid after successful payment initiation
      await bookingRef.update({
        'status': 'paid',
      });

      // Decrement the available capacity and update the room status if necessary
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(roomDoc.reference);
        int updatedCapacity = freshSnap['availableCapacity'] - 1;
        transaction.update(roomDoc.reference, {
          'availableCapacity': updatedCapacity,
          'status': updatedCapacity == 0 ? 'unavailable' : roomData['status'],
        });
      });

      // Send notification
      await sendNotification(userId, "Booking Confirmed: Your booking payment is successful.");
    } catch (e) {
      print("Error during booking process: $e"); // Log detailed error
      rethrow;
    }
  }


  Future<void> sendNotification(String userId, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'message': message,
        'isRead': false,
        'timestamp': Timestamp.now(),
      });
      _logger.i('Sent notification to userId: $userId');
    } catch (e) {
      _logger.e('Error sending notification to userId: $userId', e);
      rethrow;
    }
  }
}




// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'mpesa_service.dart';
//
// class BookingService {
//   final MpesaService _mpesaService = MpesaService();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> bookRoom({
//     required String userId,
//     required String roomId,
//     required String phoneNumber,
//     required double amount,
//     required DateTime startDate,
//     required DateTime endDate,
//   }) async {
//     try {
//       // Check if the room has available capacity
//       DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
//       if (!roomDoc.exists) {
//         throw Exception('Room document does not exist.');
//       }
//
//       Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
//       int availableCapacity = roomData['availableCapacity'];
//       if (availableCapacity <= 0) {
//         throw Exception('No available capacity');
//       }
//
//       // Create a new booking document with a pending status
//       DocumentReference bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
//         'userId': userId,
//         'roomId': roomId,
//         'phoneNumber': phoneNumber,
//         'amount': amount,
//         'startDate': startDate,
//         'endDate': endDate,
//         'status': 'pending', // Initial status
//       });
//
//       String bookingId = bookingRef.id;
//
//       // Initiate Mpesa payment
//       await _mpesaService.initiatePayment(phoneNumber, amount, bookingId);
//
//       // Store payment data in payments collection
//       await FirebaseFirestore.instance.collection('payments').add({
//         'userId': userId,
//         'bookingId': bookingId,
//         'amount': amount,
//         'phoneNumber': phoneNumber,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       // Update the booking document with status paid after successful payment initiation
//       await bookingRef.update({
//         'status': 'paid',
//       });
//
//       // Decrement the available capacity and update the room status if necessary
//       await FirebaseFirestore.instance.runTransaction((transaction) async {
//         DocumentSnapshot freshSnap = await transaction.get(roomDoc.reference);
//         int updatedCapacity = freshSnap['availableCapacity'] - 1;
//         transaction.update(roomDoc.reference, {
//           'availableCapacity': updatedCapacity,
//           'status': updatedCapacity == 0 ? 'unavailable' : roomData['status'],
//         });
//       });
//
//       // Send notification
//       await sendNotification(userId, "Booking Confirmed", "Your booking payment is successful.");
//     } catch (e) {
//       print("Error during booking process: $e"); // Log detailed error
//       rethrow;
//     }
//   }
//
//   Future<void> sendNotification(String userId, String title, String body) async {
//     // Get the FCM token for the user
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     String? fcmToken = userDoc.get('fcmToken');
//
//     if (fcmToken != null) {
//       final serverToken = 'YOUR_SERVER_KEY'; // Replace with your FCM server key
//       await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'key=$serverToken',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{'title': title, 'body': body},
//             'priority': 'high',
//             'to': fcmToken,
//           },
//         ),
//       );
//     }
//   }
// }
