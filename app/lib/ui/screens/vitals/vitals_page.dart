import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matricare_444/core/services/realtime_service.dart';

class VitalPage extends StatefulWidget {
  const VitalPage({super.key});

  @override
  State<VitalPage> createState() => _VitalPageState();
}

class _VitalPageState extends State<VitalPage> {
  final realtime = RealtimeService();
  Map<String, dynamic>? vitals;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    realtime.vitalsStream(uid).listen((data) {
      if (data == null || data.isEmpty) {
        _generateSimulatedVitals(); // AUTO-GENERATE IF EMPTY
      } else {
        setState(() => vitals = data);
        _checkAbnormalities(data);
      }
    });
  }

  // GENERATE RANDOM NORMAL VALUES
  void _generateSimulatedVitals() {
    final rand = Random();

    final simulated = {
      "mother_hr": 70 + rand.nextInt(40),           // 70–110
      "fetal_hr": 120 + rand.nextInt(40),           // 120–160
      "temperature": (97 + rand.nextDouble() * 2).toStringAsFixed(1),
      "spo2": 95 + rand.nextInt(5),                 // 95–100
      "bp_sys": 100 + rand.nextInt(30),             // 100–130
      "bp_dia": 65 + rand.nextInt(15),              // 65–80
      "resp_rate": 12 + rand.nextInt(8),            // 12–20
      "fetal_movement": rand.nextInt(12),
      "updated_at": DateTime.now().toString(),
    };

    setState(() => vitals = simulated);
    _checkAbnormalities(simulated);
  }

  // FIRESTORE → SAVE SYMPTOM
  Future<void> _logSymptom(String message) async {
    final doc = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("symptoms")
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    await doc.set({
      "message": message,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  // CHECK FOR ABNORMAL VALUES
  void _checkAbnormalities(Map<String, dynamic> v) {
    final abnormalities = <String>[];

    int mHR = int.parse(v["mother_hr"].toString());
    if (mHR < 60 || mHR > 110) abnormalities.add("Abnormal mother heart rate: $mHR");

    int fHR = int.parse(v["fetal_hr"].toString());
    if (fHR < 110 || fHR > 160) abnormalities.add("Abnormal fetal heart rate: $fHR");

    double temp = double.tryParse(v["temperature"].toString()) ?? 0;
    if (temp < 96 || temp > 100.4) abnormalities.add("Abnormal temperature: $temp°F");

    int spo2 = int.parse(v["spo2"].toString());
    if (spo2 < 94) abnormalities.add("Low oxygen level: $spo2%");

    int sys = int.parse(v["bp_sys"].toString());
    int dia = int.parse(v["bp_dia"].toString());
    if (sys < 90 || sys > 140 || dia < 60 || dia > 90) {
      abnormalities.add("Abnormal blood pressure: $sys/$dia");
    }

    int resp = int.parse(v["resp_rate"].toString());
    if (resp < 10 || resp > 24) abnormalities.add("Abnormal respiratory rate: $resp");

    // SAVE SYMPTOMS AUTOMATICALLY
    for (var s in abnormalities) {
      _logSymptom(s);
    }
  }

  // FETCH VITAL VALUE
  String v(String key, [String fallback = "--"]) {
    if (vitals == null) return fallback;
    return vitals![key]?.toString() ?? fallback;
  }

  // CHECK IF PARTICULAR VITAL IS ABNORMAL
  bool isAbnormal(String key) {
    try {
      switch (key) {
        case "mother_hr":
          int x = int.parse(v(key));
          return x < 60 || x > 110;

        case "fetal_hr":
          int x = int.parse(v(key));
          return x < 110 || x > 160;

        case "temperature":
          double x = double.parse(v(key));
          return x < 96 || x > 100.4;

        case "spo2":
          int x = int.parse(v(key));
          return x < 94;

        case "resp_rate":
          int x = int.parse(v(key));
          return x < 10 || x > 24;

        case "bp":
          int sys = int.parse(v("bp_sys"));
          int dia = int.parse(v("bp_dia"));
          return sys < 90 || sys > 140 || dia < 60 || dia > 90;
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return vitals == null
        ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
        : SingleChildScrollView(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Live Monitoring"),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _card(
                  title: "Mother HR",
                  value: v("mother_hr"),
                  unit: "bpm",
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  abnormal: isAbnormal("mother_hr")),
              _card(
                  title: "Fetal HR",
                  value: v("fetal_hr"),
                  unit: "bpm",
                  icon: Icons.child_care,
                  color: Colors.purple,
                  abnormal: isAbnormal("fetal_hr")),
            ],
          ),

          const SizedBox(height: 22),
          _sectionTitle("Body Metrics"),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _card(
                  title: "Temperature",
                  value: v("temperature"),
                  unit: "°F",
                  icon: Icons.thermostat,
                  color: Colors.orange,
                  abnormal: isAbnormal("temperature")),
              _card(
                  title: "Oxygen Level",
                  value: v("spo2"),
                  unit: "%",
                  icon: Icons.bubble_chart,
                  color: Colors.blueAccent,
                  abnormal: isAbnormal("spo2")),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _card(
                  title: "Blood Pressure",
                  value: "${v("bp_sys")}/${v("bp_dia")}",
                  unit: "mmHg",
                  icon: Icons.monitor_heart,
                  color: Colors.green,
                  abnormal: isAbnormal("bp")),
              _card(
                  title: "Resp Rate",
                  value: v("resp_rate"),
                  unit: "rpm",
                  icon: Icons.air,
                  color: Colors.teal,
                  abnormal: isAbnormal("resp_rate")),
            ],
          ),

          const SizedBox(height: 22),
          _sectionTitle("Fetal Movement"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: _box(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Last Record",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "${v("fetal_movement", "0")} Movements",
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _sectionTitle("Uterine Contractions"),

          Container(
            height: 160,
            decoration: _box(),
            child: const Center(
              child: Text("Contraction Graph Coming Soon",
                  style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 22),
          Center(
            child: Text("Last Updated: ${v("updated_at")}",
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.grey[900]),
    );
  }

  Widget _card({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required bool abnormal,
  }) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: abnormal ? Colors.red.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: abnormal ? Colors.red.withOpacity(0.25) : Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color)),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
