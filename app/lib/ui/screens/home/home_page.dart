import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:matricare_444/data/models/user_model.dart';
import 'package:matricare_444/ui/screens/home/home_tab.dart';
import 'package:matricare_444/ui/screens/vitals/vitals_page.dart';
import 'package:matricare_444/ui/screens/pregnancy/pregnancy_page.dart';
import 'package:matricare_444/ui/screens/doctor/doctor_page.dart';
import 'package:matricare_444/ui/screens/settings/settings_page.dart';
import 'package:matricare_444/ui/screens/drawer_pages/profile_page.dart';
import 'package:matricare_444/ui/screens/drawer_pages/family_access_page.dart';

import 'package:matricare_444/ui/screens/profile/profile_details.dart';
import 'package:matricare_444/core/services/realtime_service.dart';

class HomePage extends StatefulWidget {
  final String? uid;

  const HomePage({super.key, this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final realtime = RealtimeService();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  UserModel? userModel;
  Map<String, dynamic>? latestAlert;

  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleAuthChanges();
    _loadUser();
    _listenToAlerts();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  void _handleAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted && user == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
  }

  Future<void> _loadUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(current.uid)
        .get();

    setState(() {
      userModel =
      snap.exists ? UserModel.fromMap(snap.data()!) : null;
      isLoading = false;
    });
  }

  void _listenToAlerts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    realtime.alertStream(uid).listen((alert) {
      setState(() => latestAlert = alert);

      if (alert["level"] == "EMERGENCY") {
        _showEmergencyDialog(alert);
      }
    });
  }

  void _showEmergencyDialog(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 Emergency Alert"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(alert["action"] ?? "Immediate attention required."),
            const SizedBox(height: 12),
            ...List.generate(
              alert["reasons"]?.length ?? 0,
                  (i) => Text("• ${alert["reasons"][i]}"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------
  // Drawer
  // ------------------------------------------------------
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBA0C7), Color(0xFFBFAAFA)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 32, child: Icon(Icons.person, size: 36)),
                const SizedBox(height: 12),
                Text(
                  userModel?.name ?? "User",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "",
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ProfileDetailsPage(user: userModel!)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Family Access"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FamilyAccessPage(user: userModel!)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SettingsPage(user: userModel!)),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // Page Selector
  // ------------------------------------------------------
  Widget _buildBody() {
    if (userModel == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pinkAccent),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return HomeTab(latestAlert: latestAlert);
      case 1:
        return const VitalPage();
      case 2:
        return const PregnancyPage();
      case 3:
        return DoctorsPage(user: userModel!);
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // ------------------------------------------------------
  // Main Scaffold
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    final titles = [
      "MatriCare Home",
      "Vitals Dashboard",
      "Pregnancy Tracker",
      "Doctors"
    ];

    final colors = [
      Colors.pinkAccent,
      Colors.redAccent,
      Colors.pinkAccent,
      Colors.purple
    ];

    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: colors[_selectedIndex],
        actions: [
          GestureDetector(
            onTap: () => _openProfileQuickMenu(),
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.pinkAccent,
        backgroundColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart), label: "Vitals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.child_friendly), label: "Pregnancy"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: "Doctors"),
        ],
      ),
    );
  }

  void _openProfileQuickMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(userModel!.name),
              subtitle: Text(userModel!.email),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(user: userModel!),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
    );
  }
}
