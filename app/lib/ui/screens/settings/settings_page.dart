import 'package:flutter/material.dart';
import 'package:matricare_444/core/services/auth_service.dart';
import 'package:matricare_444/data/models/user_model.dart';
import 'package:matricare_444/core/routes/app_routes.dart';

class SettingsPage extends StatefulWidget {
  final UserModel user;

  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> familyAccess = [
    {"name": "Husband", "relation": "Spouse", "access": "Full Access"},
    {"name": "Mother", "relation": "Parent", "access": "Emergency Only"},
  ];

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF8A56AC),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(widget.user),

          const SizedBox(height: 20),
          _sectionTitle("Account"),
          _tile(Icons.person, "Update Profile", () {
            Navigator.pushNamed(context, "/update-profile");
          }),
          _tile(Icons.lock, "Change Password", () {
            Navigator.pushNamed(context, "/change-password");
          }),
          _tile(Icons.phone, "Update Doctor Contact", () {
            Navigator.pushNamed(
              context,
              AppRoutes.doctorContact,
              arguments: user,
            );
          }),

          const SizedBox(height: 20),
          _sectionTitle("Data Access"),
          _tile(Icons.group, "Access & Edit Permissions", _openAccessPanel),

          const SizedBox(height: 20),
          _sectionTitle("Reports"),
          _tile(Icons.analytics, "Generate Weekly Report", () {
            _openReportSheet("weekly");
          }),
          _tile(Icons.history, "View Complete Records", () {
            _openReportSheet("full");
          }),

          const SizedBox(height: 20),
          _sectionTitle("App Preferences"),

          _tile(Icons.language, "Language", () {
            Navigator.pushNamed(context, '/language');
          }),

          _tile(Icons.palette, "Theme", () {
            Navigator.pushNamed(context, '/theme');
          }),

          _tile(Icons.notifications, "Notification Settings", () {
            Navigator.pushNamed(context, '/notification-settings');
          }),

          const SizedBox(height: 20),
          _sectionTitle("Support"),

          _tile(Icons.help_center, "Help Center", () {
            Navigator.pushNamed(context, '/help-center');
          }),

          _tile(Icons.feedback, "Send Feedback", () {
            Navigator.pushNamed(context, '/feedback');
          }),

          const SizedBox(height: 20),

          _logoutButton(context),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(UserModel? user) {
    final displayName = user?.name ?? "Unknown User";
    final displayEmail = user?.email ?? "No Email";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9C4FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF8A56AC),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  displayEmail,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A156B),
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: Icon(icon, color: const Color(0xFF8A56AC)),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // ---------------- ACCESS PANEL ----------------
  void _openAccessPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Family Access Control",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...familyAccess.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF8A56AC),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member["name"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(member["relation"], style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE4FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(member["access"]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModal(() {
                              familyAccess.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        )
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A56AC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => _addFamilyMember(setModal),
                  icon: const Icon(Icons.add,color: Colors.white,),
                  label: const Text("Add Member",style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addFamilyMember(void Function(void Function()) modalSetState) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    String accessLevel = "View Only";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Family Member"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 20),
            TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: "Relation")),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: accessLevel,
              decoration: const InputDecoration(labelText: "Access Level"),
              items: const [
                DropdownMenuItem(value: "View Only", child: Text("View Only")),
                DropdownMenuItem(value: "Emergency Only", child: Text("Emergency Only")),
                DropdownMenuItem(value: "Full Access", child: Text("Full Access")),
              ],
              onChanged: (val) => accessLevel = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              modalSetState(() {
                familyAccess.add({
                  "name": nameCtrl.text,
                  "relation": relationCtrl.text,
                  "access": accessLevel,
                });
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A56AC)),
            child: const Text("Add",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  void _openReportSheet(String type) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == "weekly" ? "Generate Weekly Report" : "Full Medical Record",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your report will include vitals, fetal monitoring history, alerts, and doctor notes.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A56AC),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
              label: Text(type == "weekly" ? "Generate Weekly PDF" : "Export Full Report",style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await AuthService().logout();
        Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text("Logout", style: TextStyle(fontSize: 16)),
    );
  }
}
