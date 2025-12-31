// lib/core/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matricare_444/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔥 Expose current user like a proper service layer
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // PASSWORD MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Change password for logged-in user
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in.");
    await user.updatePassword(newPassword);
    await user.reload();
  }

  Future<void> addFamilyRequest(String primaryUid, Map<String, String> data) async {
    final ref = FirebaseFirestore.instance
        .collection('familyAccessRequests')
        .doc(primaryUid)
        .collection('requests');
    await ref.add({
      ...data,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reload user to get fresh auth state
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in.");
    await user.reload();
  }

  // ---------------------------------------------------------------------------
  // AUTH + FIRESTORE PROFILE CREATION
  // ---------------------------------------------------------------------------

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String age,
    required String role,
    required String dateOfBirth,
    required String phoneNumber,
    required String doctorPhno,
    required String license,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final user = UserModel(
        uid: uid,
        email: email,
        name: name,
        age: age,
        role: role,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        doctorPhno: doctorPhno,
        license: license,
        deliveryDate: null,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } catch (e) {
      print("AuthService.register error: $e");
      rethrow;
    }
  }

  // More consistent naming — keep one final method for logout
  Future<void> logout() async => await _auth.signOut();

  Future<UserModel> getUserModel() async {
    final uid = _auth.currentUser!.uid;
    final snap = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(snap.data());
  }

  Future<UserModel?> signInAndFetchUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        final fallback = UserModel(
          uid: uid,
          email: email,
          name: '',
          age: '',
          role: '',
          dateOfBirth: '',
          phoneNumber: '',
          doctorPhno: '',
          license: '',
          deliveryDate: null,
        );
        await _firestore.collection('users').doc(uid).set(fallback.toMap());
        return fallback;
      }

      return UserModel.fromMap(doc.data());
    } catch (e) {
      print("AuthService.signIn error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
