import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/family_member.dart';
import 'dart:io';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<DocumentSnapshot> getUserDoc() async {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final doc = _db.collection('users').doc(uid);
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    await doc.set(data, SetOptions(merge: true));
  }

  Future<String> uploadProfileImage(File file) async {
    final ref = _storage.ref().child('profiles/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    final url = await task.ref.getDownloadURL();
    await updateProfile(photoUrl: url);
    return url;
  }

  // Doctor contact
  Future<void> updateDoctorContact(Map<String, dynamic> contact) async {
    await _db.collection('users').doc(uid).set({'doctorContact': contact}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getDoctorContact() async {
    final snap = await getUserDoc();
    return (snap.data() as Map<String, dynamic>?)?['doctorContact'] as Map<String, dynamic>?;
  }

  // Preferences
  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    await _db.collection('users').doc(uid).set({'preferences': prefs}, SetOptions(merge: true));
  }

  // Family access management
  Stream<List<FamilyMember>> familyAccessStream() {
    return _db.collection('users').doc(uid).collection('familyAccess').snapshots().map(
            (snap) => snap.docs.map((d) => FamilyMember.fromDoc(d.id, d.data())).toList()
    );
  }

  Future<void> addFamilyMember(FamilyMember m) async {
    await _db.collection('users').doc(uid).collection('familyAccess').add(m.toMap());
  }

  Future<void> updateFamilyMember(FamilyMember m) async {
    await _db.collection('users').doc(uid).collection('familyAccess').doc(m.id).set(m.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteFamilyMember(String id) async {
    await _db.collection('users').doc(uid).collection('familyAccess').doc(id).delete();
  }

  // Reports meta
  Future<void> saveReportMeta(Map<String, dynamic> meta) async {
    await _db.collection('users').doc(uid).collection('reports').add(meta);
  }
}
