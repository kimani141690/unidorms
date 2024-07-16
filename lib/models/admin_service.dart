import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loadAdminData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<int> getTotalRooms() async {
    QuerySnapshot roomSnapshot = await _firestore.collection('rooms').get();
    return roomSnapshot.docs.length;
  }

  Future<int> getOccupiedRooms() async {
    QuerySnapshot roomSnapshot = await _firestore.collection('rooms').where('status', isEqualTo: 'occupied').get();
    return roomSnapshot.docs.length;
  }

  Future<int> getBookedRooms() async {
    QuerySnapshot roomSnapshot = await _firestore.collection('bookings').where('status', isEqualTo: 'booked').get();
    return roomSnapshot.docs.length;
  }

  Future<int> getTotalStudents() async {
    QuerySnapshot studentSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'student').get();
    return studentSnapshot.docs.length;
  }

  Future<int> getStudentsInHostel() async {
    QuerySnapshot studentSnapshot = await _firestore.collection('bookings').where('status', isEqualTo: 'checkedin').get();
    return studentSnapshot.docs.length;
  }

  Future<int> getCheckedOutStudents() async { // Updated method
    QuerySnapshot studentSnapshot = await _firestore.collection('bookings').where('status', isEqualTo: 'checkedout').get();
    return studentSnapshot.docs.length;
  }

  Future<int> getTotalReservations() async { // Updated method
    QuerySnapshot reservationSnapshot = await _firestore.collection('reservations').get();
    return reservationSnapshot.docs.length;
  }

  Future<int> getActiveReservations() async { // Updated method
    QuerySnapshot reservationSnapshot = await _firestore.collection('reservations').where('status', isEqualTo: 'active').get();
    return reservationSnapshot.docs.length;
  }

  Future<int> getCancelledReservations() async { // Updated method
    QuerySnapshot reservationSnapshot = await _firestore.collection('reservations').where('status', isEqualTo: 'cancelled').get();
    return reservationSnapshot.docs.length;
  }

  Future<int> getGuestRequests() async {
    QuerySnapshot guestSnapshot = await _firestore.collection('guest_visits').get();
    return guestSnapshot.docs.length;
  }

  Future<int> getApprovedGuestRequests() async {
    QuerySnapshot guestSnapshot = await _firestore.collection('guest_visits').where('status', isEqualTo: 'approved').get();
    return guestSnapshot.docs.length;
  }

  Future<int> getRejectedGuestRequests() async {
    QuerySnapshot guestSnapshot = await _firestore.collection('guest_visits').where('status', isEqualTo: 'rejected').get();
    return guestSnapshot.docs.length;
  }

  Future<int> getMaintenanceRequests() async {
    QuerySnapshot maintenanceSnapshot = await _firestore.collection('maintenance_tickets').get();
    return maintenanceSnapshot.docs.length;
  }

  Future<int> getResolvedMaintenanceRequests() async {
    QuerySnapshot maintenanceSnapshot = await _firestore.collection('maintenance_tickets').where('status', isEqualTo: 'resolved').get();
    return maintenanceSnapshot.docs.length;
  }

  Future<double> getTotalRentCollected() async {
    QuerySnapshot rentSnapshot = await _firestore.collection('payments').get();
    double totalRent = 0.0;
    for (var doc in rentSnapshot.docs) {
      totalRent += doc['amount'] ?? 0.0;
    }
    return totalRent;
  }


}
