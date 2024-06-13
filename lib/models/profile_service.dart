import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateProfile(String userId, String username, String email, String phoneNumber, String roomNumber, File? profileImage) async {
    String? profileImageUrl;

    if (profileImage != null) {
      UploadTask uploadTask = _storage.ref().child('profile_images/$userId').putFile(profileImage);
      TaskSnapshot taskSnapshot = await uploadTask;
      profileImageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    await _firestore.collection('users').doc(userId).update({
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'roomNumber': roomNumber,
      if (profileImageUrl != null) 'profileImage': profileImageUrl,
    });
  }
}
