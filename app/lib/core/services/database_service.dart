// lib/core/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:matricare_444/data/models/user_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ---------------- Save user profile (overwrite or create)
  Future<void> saveUserProfile(String uid, UserModel user) async {
    await _db.child('users/$uid').set(user.toMap());
  }

  // ---------------- Update partial profile fields (merge)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> patch) async {
    await _db.child('users/$uid').update(patch);
  }

  // ---------------- Add doctor under user
  Future<void> addDoctor(String uid, Map<String, dynamic> doctorData) async {
    final newKey = _db.child('users/$uid/doctors').push().key;
    await _db.child('users/$uid/doctors/$newKey').set(doctorData);
  }

  // ---------------- Add guardian / family member
  Future<void> addGuardian(String uid, Map<String, dynamic> guardianData) async {
    final newKey = _db.child('users/$uid/guardians').push().key;
    await _db.child('users/$uid/guardians/$newKey').set(guardianData);
  }

  // ---------------- Generate a simple access token for family member login
  Future<String> generateAccessToken(String uid) async {
    final token = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.child('users/$uid/accessTokens/$token').set({
      'active': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return token;
  }

  // ---------------- Validate access token and return primaryUid if found
  Future<String?> validateAccessToken(String token) async {
    final snapshot = await _db.child('users').get();
    if (!snapshot.exists) return null;
    for (final userSnap in snapshot.children) {
      if (userSnap.child('accessTokens/$token').exists) {
        return userSnap.key;
      }
    }
    return null;
  }

  // ---------------- Vitals stream (Realtime)
  DatabaseReference vitalsRef(String uid) => _db.child('users/$uid/vitals');
  Stream<DatabaseEvent> vitalsStream(String uid) => vitalsRef(uid).onValue;

  // ---------------- Generate random vitals (testing helper)
  Future<void> generateRandomVitals(String uid) async {
    final rng = DateTime.now().millisecondsSinceEpoch % 100;
    await vitalsRef(uid).set({
      'heartRate': 60 + (rng % 40),
      'bloodPressure': '${100 + (rng % 20)}/${60 + (rng % 20)}',
      'temperature': (97 + (rng % 5)).toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
