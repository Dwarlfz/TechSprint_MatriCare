import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class RealtimeService {
  final database = FirebaseDatabase.instance;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Push random vitals for testing
  Future<void> generateVitals(String uid) async {
    final rng = Random();
    await _db.child('vitals/$uid').set({
      'heartRate': 60 + rng.nextInt(40),
      'bloodPressure': '${100 + rng.nextInt(20)}/${60 + rng.nextInt(20)}',
      'temperature': (97 + rng.nextDouble() * 3).toStringAsFixed(1),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Push random pregnancy data
  Future<void> generatePregnancy(String uid) async {
    final rng = Random();
    await _db.child('pregnancy/$uid').set({
      'week': 10 + rng.nextInt(30),
      'fetalHeartRate': 120 + rng.nextInt(30),
      'alerts': ['Check Iron Level', 'Stay hydrated'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // // Stream vitals for UI
  // Stream<DatabaseEvent> vitalsStream(String uid) {
  //   return _db.child('vitals/$uid').onValue;
  // }

  // Stream pregnancy data for UI
  Stream<DatabaseEvent> pregnancyStream(String uid) {
    return _db.child('pregnancy/$uid').onValue;
  }

  Stream<Map<String, dynamic>> vitalsStream(String uid) {
    return database.ref("vitals/$uid").onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    });
  }

  Stream<Map<String, dynamic>> alertStream(String uid) {
    return database.ref("alerts/$uid").onChildAdded.map((event) {
      final data = event.snapshot.value;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    });
  }
}
