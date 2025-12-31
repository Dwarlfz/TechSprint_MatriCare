import 'package:flutter/material.dart';
import 'package:matricare_444/ui/widgets/custom_card.dart';
import 'package:matricare_444/ui/screens/pregnancy/pregnancy_progress_chart.dart';
class HomeTab extends StatelessWidget {
  final Map<String, dynamic>? latestAlert;
  final weeklyData = {11: 78, 12: 65, 13: 90};
  final weeklyInfo = {
    12: {
      "symptoms": ["Nausea"],
      "abnormalVitals": ["Low BP"],
      "selfCare": {"hydration": 55, "sleep": 70, "stress": 40},
    }
  };
  final Map<int, double> weeklyHealthScores = {
    1: 75,
    2: 78,
    3: 80,
    4: 82,
    5: 85,
    6: 88,
    7: 90,
  };

  HomeTab({super.key, this.latestAlert});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ALERT / TIP CARD
          CustomCard(
            title: latestAlert?["level"] ?? "Today's Tip",
            subtitle: latestAlert?["reasons"]?[0] ?? "Stay hydrated and rest",
            icon: Icons.local_fire_department,
            color: Colors.pinkAccent.shade200,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF80AB), Color(0xFFFF4081)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          PregnancyProgressChart(
            weeklyData: weeklyData,
            weeklyInfo: weeklyInfo,
          ),
          const SizedBox(height: 24),
          // Example: Tips Section
          _sectionTitle("Health Tips"),
          const SizedBox(height: 10),
          _tipCard("Drink plenty of water to stay hydrated."),
          _tipCard("Take short walks to keep your body active."),
          _tipCard("Maintain a healthy diet rich in iron and protein."),
        ],
      ),
    );
  }

  Widget _quickCard(BuildContext context, IconData icon, String title, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A1B9A),
        ),
      ),
    );
  }

  Widget _tipCard(String tip) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
