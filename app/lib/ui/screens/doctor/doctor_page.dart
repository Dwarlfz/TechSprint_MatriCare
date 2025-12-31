import 'package:flutter/material.dart';
import 'package:matricare_444/data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DoctorsPage extends StatefulWidget {
  final UserModel? user;

  const DoctorsPage({super.key, required this.user});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

/* ======================= MAP SHEET ======================= */

class _HospitalMapSheet extends StatefulWidget {
  const _HospitalMapSheet();

  @override
  State<_HospitalMapSheet> createState() => _HospitalMapSheetState();
}

class _HospitalMapSheetState extends State<_HospitalMapSheet> {
  late GoogleMapController _mapController;

  final LatLng _primaryHospital =
  const LatLng(19.0330, 73.0297); // Rainbow Hospital

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Primary Hospital Marker
    _markers.add(
      Marker(
        markerId: const MarkerId("primaryHospital"),
        position: _primaryHospital,
        infoWindow: const InfoWindow(
          title: "Rainbow Women's Hospital",
          snippet: "Doctor In-Charge Hospital",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
    );

    // Dummy Nearby Hospitals (IMPORTANT: Maps do NOT auto-load hospitals)
    _markers.addAll([
      Marker(
        markerId: const MarkerId("nearby1"),
        position: const LatLng(19.0362, 73.0271),
        infoWindow: const InfoWindow(title: "City Maternity Hospital"),
      ),
      Marker(
        markerId: const MarkerId("nearby2"),
        position: const LatLng(19.0308, 73.0344),
        infoWindow: const InfoWindow(title: "Care Women & Child Hospital"),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Nearby Hospitals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _primaryHospital,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================= MAIN PAGE ======================= */

class _DoctorsPageState extends State<DoctorsPage> {
  List<Map<String, String>> doctors = [];

  @override
  void initState() {
    super.initState();

    if (widget.user != null && widget.user!.doctorPhno.isNotEmpty) {
      doctors.add({
        "name": "Dr. ${widget.user!.name}",
        "spec": "Gynecologist / OB-GYN",
        "phone": widget.user!.doctorPhno,
      });
    }
  }

  void _openMapSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) => const _HospitalMapSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hospitalCard(),
              const SizedBox(height: 20),
              const Text(
                "Your Medical Support Team",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A156B),
                ),
              ),
              const SizedBox(height: 16),
              ...doctors.map(
                    (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _doctorCard(
                    name: doc["name"]!,
                    specialization: doc["spec"]!,
                    phone: doc["phone"]!,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _doctorCard(
                name: "Nurse Consultant",
                specialization: "24/7 Maternity Nursing",
                phone: "+91 98202 33445",
              ),
              const SizedBox(height: 14),
              _doctorCard(
                name: "Emergency Line",
                specialization: "Ambulance & Urgent Care",
                phone: "108",
                highlight: true,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF8A56AC),
            onPressed: _addDoctorSheet,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _addDoctorSheet() {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Doctor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Doctor Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: specCtrl,
              decoration: const InputDecoration(labelText: "Specialization"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty &&
                    phoneCtrl.text.isNotEmpty) {
                  setState(() {
                    doctors.add({
                      "name": nameCtrl.text,
                      "spec": specCtrl.text,
                      "phone": phoneCtrl.text,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hospitalCard() {
    const hospitalName = "Rainbow Women's Hospital";
    const hospitalAddress = "Sector 12, Mumbai, MH 400703";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hospital Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A156B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "$hospitalName\n$hospitalAddress",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8A56AC),
            ),
            onPressed: _openMapSheet,
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              "Open in Maps",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorCard({
    required String name,
    required String specialization,
    required String phone,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFE4E6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
            highlight ? Colors.redAccent : const Color(0xFFCEB9FF),
            child: const Icon(Icons.medical_services,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(phone),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              launchUrl(Uri.parse("tel:$phone"));
            },
            icon: const Icon(Icons.call, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
