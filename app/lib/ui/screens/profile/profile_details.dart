import 'package:flutter/material.dart';
import 'package:matricare_444/data/models/user_model.dart';

class ProfileDetailsPage extends StatelessWidget {
  final UserModel user;

  const ProfileDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text("Profile Details"),
        backgroundColor: const Color(0xFF8A56AC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER CARD ----------------
            _headerCard(),

            const SizedBox(height: 22),
            _sectionTitle("Personal Information"),
            _infoTile("Name", user.name),
            _infoTile("Email", user.email),
            _infoTile("Age", user.age),
            _infoTile("Date of Birth", user.dateOfBirth),

            const SizedBox(height: 22),
            _sectionTitle("Contact Details"),
            _infoTile("Phone Number", user.phoneNumber),
            _infoTile("Doctor Phone", user.doctorPhno),

            const SizedBox(height: 22),
            _sectionTitle("Medical Info"),
            _infoTile("License Number", user.license),
            _infoTile("Delivery Date",
                user.deliveryDate == null ? "Not Updated" : user.deliveryDate!),

            const SizedBox(height: 22),
            _editButton(context),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER CARD ----------------
  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9C4FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF8A56AC),
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A156B),
        ),
      ),
    );
  }

  // ---------------- INFO TILE ----------------
  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ---------------- EDIT BUTTON ----------------
  Widget _editButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          "/update-profile",
          arguments: user,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A56AC),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: const Text(
        "Edit Profile",
        style: TextStyle(fontSize: 16,color: Colors.white),
      ),
    );
  }
}