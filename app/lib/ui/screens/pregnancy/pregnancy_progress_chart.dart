import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PregnancyProgressChart extends StatelessWidget {
  /// week -> score (can be int or double)
  final Map<int, num> weeklyData;

  /// week -> details map:
  /// {
  ///   "symptoms": ["Nausea"],
  ///   "abnormalVitals": ["Low BP"],
  ///   "selfCare": {"hydration": 55, "sleep": 70, "stress": 40}
  /// }
  final Map<int, Map<String, dynamic>> weeklyInfo;

  const PregnancyProgressChart({
    super.key,
    required this.weeklyData,
    required this.weeklyInfo,
  });

  Color _scoreColor(num v) {
    final double vv = v.toDouble();
    if (vv >= 80) return Colors.green;
    if (vv >= 55) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final spots = weeklyData.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pregnancy Health Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      // keep default background; we return items below
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            "Week ${spot.x.toInt()}\nScore: ${spot.y.toInt()}",
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                      if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) return;
                      final week = response.lineBarSpots!.first.x.toInt();
                      _showWeekDetail(context, week);
                    },
                  ),

                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "W${value.toInt()}",
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.pinkAccent,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.pinkAccent.withOpacity(0.28),
                            Colors.pinkAccent.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(show: true),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekDetail(BuildContext context, int week) {
    final data = weeklyInfo[week];

    if (data == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Week $week"),
          content: const Text("No data recorded for this week."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
        ),
      );
      return;
    }

    final symptoms = List<String>.from(data["symptoms"] ?? []);
    final abn = List<String>.from(data["abnormalVitals"] ?? []);
    final self = Map<String, dynamic>.from(data["selfCare"] ?? {});
    final score = weeklyData[week] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                "Week $week Health Report",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink),
                  const SizedBox(width: 8),
                  Text(
                    "Health Score: ${score.toInt()}",
                    style: TextStyle(
                      fontSize: 17,
                      color: _scoreColor(score),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _section("Symptoms", symptoms),
              const SizedBox(height: 16),

              _section("Abnormal Vitals", abn),
              const SizedBox(height: 16),

              _selfCareSection(self),
              const SizedBox(height: 22),

              const Text("AI Doctor Recommendations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_genRecommendations(symptoms, abn, self), style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String title, List<String> items) {
    if (items.isEmpty) {
      return Text("$title: No issues", style: const TextStyle(fontSize: 14));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map(
              (e) => Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.grey),
              const SizedBox(width: 6),
              Text(e, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selfCareSection(Map<String, dynamic> self) {
    if (self.isEmpty) {
      return const Text("Self-care data not available.");
    }

    int hydration = (self['hydration'] is num) ? (self['hydration'] as num).toInt() : 0;
    int sleep = (self['sleep'] is num) ? (self['sleep'] as num).toInt() : 0;
    int stress = (self['stress'] is num) ? (self['stress'] as num).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Self Care Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _bar("Hydration", hydration),
        _bar("Sleep Quality", sleep),
        _bar("Stress Level", (100 - stress)),
      ],
    );
  }

  Widget _bar(String label, int value) {
    final double widthFactor = (value.clamp(0, 100) / 100.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ($value%)"),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[300]),
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              alignment: Alignment.centerLeft,
              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.pinkAccent)),
            ),
          ),
        ],
      ),
    );
  }

  String _genRecommendations(List<String> symptoms, List<String> abn, Map<String, dynamic> self) {
    final List<String> out = [];

    if (symptoms.any((s) => s.toLowerCase().contains('headache'))) {
      out.add("Stay hydrated and rest adequately.");
    }
    if (symptoms.any((s) => s.toLowerCase().contains('nausea'))) {
      out.add("Eat small frequent meals, avoid spicy food.");
    }
    if (abn.any((a) => a.toLowerCase().contains('low bp'))) {
      out.add("Increase salt intake moderately and stay hydrated.");
    }
    if (abn.any((a) => a.toLowerCase().contains('high'))) {
      out.add("Monitor stress and follow up with your doctor.");
    }
    if ((self["hydration"] ?? 100) is num && (self["hydration"] as num) < 50) {
      out.add("Drink at least 2–3L of water today.");
    }
    if ((self["sleep"] ?? 100) is num && (self["sleep"] as num) < 60) {
      out.add("Try to get 7–8 hours of sleep tonight.");
    }

    return out.isEmpty ? "Everything looks stable this week. Keep it up!" : out.join("\n");
  }
}
