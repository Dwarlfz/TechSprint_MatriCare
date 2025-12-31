// lib/ui/screens/pregnancy/pregnancy_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// PregnancyPage
///
/// - Reads symptoms from: users/{uid}/symptoms (one document per symptom)
/// - Appointments: users/{uid}/appointments
/// - Reports: users/{uid}/reports
///
/// This file stays in sync with the VitalPage auto-logging routine which writes
/// symptom docs into users/{uid}/symptoms/{timestampId}.
class PregnancyPage extends StatefulWidget {
  const PregnancyPage({super.key});

  @override
  State<PregnancyPage> createState() => _PregnancyPageState();
}

class _PregnancyPageState extends State<PregnancyPage> {
  DateTime? _dueDate;
  static const int _pregnancyDays = 280; // average pregnancy length
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadDueDate();
  }

  Future<void> _loadDueDate() async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['dueDate'] != null) {
        setState(() {
          _dueDate = (data['dueDate'] as Timestamp).toDate();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = _dueDate != null ? _dueDate!.subtract(const Duration(days: _pregnancyDays)) : null;
    final daysElapsed = (startDate == null) ? 0 : max(0, today.difference(startDate).inDays);
    final percent = (startDate == null) ? 0.0 : (daysElapsed / _pregnancyDays).clamp(0.0, 1.0);
    final week = (daysElapsed / 7).floor() + 1;
    final weeksRemaining = _dueDate == null ? null : max(0, _dueDate!.difference(today).inDays ~/ 7);
    final trimester = _computeTrimester(daysElapsed);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle("Weekly Progress"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardStyle(),
          child: Column(children: [
            Text(
              'Week ${_dueDate == null ? "—" : week.clamp(1, 42)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _dueDate == null ? "Set expected delivery date to see progress." : "You're making great progress!",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 140,
              width: 140,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.pinkAccent),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(percent * 100).toStringAsFixed(_percentPrecision(percent))}%',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    _dueDate == null ? 'Progress' : '${_formatDays(daysElapsed)} since start',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ])
              ]),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _progressMetric("Due In", _dueDate == null ? '—' : '${weeksRemaining} wk'),
              _progressMetric("Trimester", _dueDate == null ? '—' : trimester),
              _progressMetric("Week", _dueDate == null ? '—' : '${week.clamp(1, 42)}'),
            ]),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickDueDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_dueDate == null ? 'Set Due Date' : 'Change Due Date'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            ),
          ]),
        ),

        const SizedBox(height: 26),
        _sectionTitle("Baby Size Comparison"),
        const SizedBox(height: 8),
        _babySizeCard(week),

        const SizedBox(height: 26),
        _sectionTitle("Trimester Timeline"),
        const SizedBox(height: 8),
        _trimesterCard(week),

        const SizedBox(height: 26),
        _sectionTitle("Kick Counter & Movements"),
        const SizedBox(height: 8),
        _kickCounterCard(),

        const SizedBox(height: 26),
        _sectionTitle("Symptoms Tracker"),
        const SizedBox(height: 8),
        _symptomTrackerCard(),

        const SizedBox(height: 26),
        _sectionTitle("Upcoming Appointments"),
        const SizedBox(height: 8),
        _appointmentsCard(),

        const SizedBox(height: 26),
        _sectionTitle("Doctor Reports"),
        const SizedBox(height: 8),
        _reportsCard(),

        const SizedBox(height: 26),
        _sectionTitle("Doctor Notes"),
        const SizedBox(height: 8),
        _doctorNotesCard(),

        const SizedBox(height: 30),
      ]),
    );
  }

  // -----------------------
  // Helpers & widgets
  // -----------------------

  int _percentPrecision(double p) {
    if (p * 100 < 1) return 2;
    return 0;
  }

  String _formatDays(int days) {
    if (days <= 0) return '0 days';
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    final w = days ~/ 7;
    final r = days % 7;
    return r == 0 ? '$w wk${w > 1 ? "s" : ""}' : '$w wk ${r}d';
  }

  String _computeTrimester(int daysElapsed) {
    final weeks = (daysElapsed / 7).floor() + 1;
    if (weeks <= 12) return '1st';
    if (weeks <= 27) return '2nd';
    if (weeks <= 42) return '3rd';
    return 'Post-term';
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 4),
          color: Colors.grey.withOpacity(0.12),
        )
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87));
  }

  Widget _progressMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  // -----------------------
  // Baby size card (fixed overflow)
  // -----------------------

  Widget _babySizeCard(int week) {
    final Map<int, String> sizeMap = {
      1: 'Tiny',
      6: 'Poppy seed',
      12: 'Lime',
      16: 'Avocado',
      20: 'Banana',
      28: 'Eggplant',
      36: 'Cabbage',
      40: 'Watermelon',
    };

    int useWeek = week.clamp(1, 42);
    int closest = sizeMap.keys.reduce((a, b) => (((a - useWeek).abs()) < ((b - useWeek).abs())) ? a : b);
    String approx = sizeMap[closest] ?? 'Baby';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardStyle(),
      child: Row(children: [
        // constrained emoji avatar to prevent overflow
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text("🥑", style: TextStyle(fontSize: 26)),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Baby is approximately: $approx', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Week $useWeek • Estimated growth', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ]),
        )
      ]),
    );
  }

  Widget _timelineRow(String title, String subtitle, bool completed) {
    return Row(children: [
      Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.green : Colors.grey),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ]),
    ]);
  }

  Widget _trimesterCard(int currentWeek) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardStyle(),
      child: Column(
        children: [
          _timelineRow('1st Trimester', 'Weeks 0–12', currentWeek > 12),
          const SizedBox(height: 12),
          _timelineRow('2nd Trimester', 'Weeks 13–27', currentWeek > 27),
          const SizedBox(height: 12),
          _timelineRow('3rd Trimester', 'Weeks 28–40', currentWeek > 40),
        ],
      ),
    );
  }

  Widget _kickCounterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardStyle(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Baby Movements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Today\'s Kicks: 0', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kick counter tapped')));
            },
            icon: const Icon(Icons.touch_app, size: 18),
            label: const Text('Count Now'),
          )
        ])
      ]),
    );
  }

  // -----------------------
  // Symptoms tracker: reads the symptoms collection and displays individual docs
  // -----------------------

  Widget _symptomTrackerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardStyle(),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('users').doc(uid).collection('symptoms').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
              child: Text('Error loading symptoms: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Column(children: [
              const Text('No symptoms logged yet', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _addSymptomLocal, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text('Add Symptom')),
            ]);
          }

          return Column(
            children: [
              ...docs.map((d) {
                final data = d.data();
                final label = (data['label'] as String?) ?? (data['message'] as String?) ?? (data['type'] as String?) ?? '(symptom)';
                final value = (data['value'] as String?) ?? '';
                final ts = _parseTimestamp(data['timestamp']);
                final dateText = ts != null ? _readableDate(ts) : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    const Icon(Icons.circle, size: 10, color: Colors.pinkAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        if (value.isNotEmpty) Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        if (dateText.isNotEmpty) Text(dateText, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ]),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _db.collection('users').doc(uid).collection('symptoms').doc(d.id).delete();
                      },
                      icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
                    ),
                  ]),
                );
              }).toList(),
              const SizedBox(height: 6),
              ElevatedButton(onPressed: _addSymptomLocal, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text('Add Symptom')),
            ],
          );
        },
      ),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _addSymptomLocal() async {
    final symptomCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Add Symptom'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: symptomCtrl, decoration: const InputDecoration(labelText: 'Symptom (e.g. Nausea)')),
              const SizedBox(height: 8),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final text = symptomCtrl.text.trim();
                final note = noteCtrl.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a symptom')));
                  return;
                }
                final docRef = _db.collection('users').doc(uid).collection('symptoms').doc();
                await docRef.set({
                  'label': text,
                  'value': note,
                  'timestamp': Timestamp.fromDate(DateTime.now()),
                });
                Navigator.pop(c);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  String _readableDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  // -----------------------
  // Appointments (firestore)
  // -----------------------

  Widget _appointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardStyle(),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('users').doc(uid).collection('appointments').orderBy('date', descending: false).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Text('Error loading appointments: ${snap.error}', style: const TextStyle(color: Colors.red));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Column(children: [
              const Padding(padding: EdgeInsets.all(8.0), child: Text('No upcoming appointments')),
              const SizedBox(height: 6),
              ElevatedButton(onPressed: _addAppointmentDialog, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text('Add Appointment'))
            ]);
          }

          return Column(children: [
            ...docs.map((d) {
              final data = d.data();
              final ts = data['date'] as Timestamp?;
              final date = ts?.toDate();
              final type = data['type'] as String? ?? 'Appointment';
              final recommendedBy = data['recommendedBy'] as String? ?? 'manual';
              final notes = data['notes'] as String? ?? '';
              final dateText = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}' : 'TBD';
              return Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text('$type', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  Text(dateText, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
                Row(children: [
                  Text('Recommended by: $recommendedBy', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _editAppointmentDialog(d.id, data),
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _db.collection('users').doc(uid).collection('appointments').doc(d.id).delete();
                    },
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                  ),
                ]),
                if (notes.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 6, top: 6), child: Text(notes, style: const TextStyle(fontSize: 13))),
                const Divider(),
              ]);
            }).toList(),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addAppointmentDialog, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text('Add Appointment'))
          ]);
        },
      ),
    );
  }

  Future<void> _addAppointmentDialog() async {
    final typeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime chosen = DateTime.now().add(const Duration(days: 7));
    String recommendedBy = 'manual';

    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Add Appointment'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type (e.g. Doctor Visit)')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text('Date: ${chosen.day}/${chosen.month}/${chosen.year} ${chosen.hour}:${chosen.minute}')),
                IconButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: chosen, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
                    if (picked != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 10, minute: 0));
                      if (time != null) {
                        setState(() {
                          chosen = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                        });
                      } else {
                        setState(() {
                          chosen = DateTime(picked.year, picked.month, picked.day, chosen.hour, chosen.minute);
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                )
              ]),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: recommendedBy,
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'ai', child: Text('AI Recommendation')),
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor Recommendation')),
                ],
                onChanged: (v) {
                  if (v != null) recommendedBy = v;
                },
                decoration: const InputDecoration(labelText: 'Suggested by'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final type = typeCtrl.text.trim().isEmpty ? 'Doctor Visit' : typeCtrl.text.trim();
                await _db.collection('users').doc(uid).collection('appointments').doc().set({
                  'type': type,
                  'date': Timestamp.fromDate(chosen),
                  'notes': notesCtrl.text.trim(),
                  'recommendedBy': recommendedBy,
                });
                Navigator.pop(c);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  Future<void> _editAppointmentDialog(String docId, Map<String, dynamic> existing) async {
    final typeCtrl = TextEditingController(text: existing['type'] as String? ?? '');
    final notesCtrl = TextEditingController(text: existing['notes'] as String? ?? '');
    DateTime chosen = (existing['date'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7));
    String recommendedBy = existing['recommendedBy'] as String? ?? 'manual';

    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Edit Appointment'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Type')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text('Date: ${chosen.day}/${chosen.month}/${chosen.year} ${chosen.hour}:${chosen.minute}')),
                IconButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: chosen, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
                    if (picked != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: chosen.hour, minute: chosen.minute));
                      if (time != null) setState(() => chosen = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
                      else setState(() => chosen = DateTime(picked.year, picked.month, picked.day, chosen.hour, chosen.minute));
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                )
              ]),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: recommendedBy,
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'ai', child: Text('AI Recommendation')),
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor Recommendation')),
                ],
                onChanged: (v) {
                  if (v != null) recommendedBy = v;
                },
                decoration: const InputDecoration(labelText: 'Suggested by'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final type = typeCtrl.text.trim().isEmpty ? 'Doctor Visit' : typeCtrl.text.trim();
                await _db.collection('users').doc(uid).collection('appointments').doc(docId).set({
                  'type': type,
                  'date': Timestamp.fromDate(chosen),
                  'notes': notesCtrl.text.trim(),
                  'recommendedBy': recommendedBy,
                }, SetOptions(merge: true));
                Navigator.pop(c);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  // -----------------------
  // Reports (read from Firestore; View -> dialog with copy link)
  // -----------------------

  Widget _reportsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardStyle(),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('users').doc(uid).collection('reports').orderBy('date', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Text('Error loading reports: ${snap.error}', style: const TextStyle(color: Colors.red));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Column(children: [
              const Padding(padding: EdgeInsets.all(8.0), child: Text('No reports available')),
              const SizedBox(height: 6),
              ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No reports to show'))), style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text('View Full Report'))
            ]);
          }

          return Column(children: [
            ...docs.map((d) {
              final data = d.data();
              final title = data['title'] as String? ?? 'Report';
              final ts = data['date'] as Timestamp?;
              final dateText = ts != null ? _readableDate(ts.toDate()) : 'Unknown date';
              final fileUrl = data['fileUrl'] as String? ?? '';
              return Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  Text(dateText, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
                Row(children: [
                  Text(fileUrl.isNotEmpty ? 'File available' : 'No file', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showReportDialog(title, fileUrl),
                    child: const Text('View Report'),
                  )
                ]),
                const Divider(),
              ]);
            }).toList()
          ]);
        },
      ),
    );
  }

  Future<void> _showReportDialog(String title, String fileUrl) async {
    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text(title),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(fileUrl.isNotEmpty ? 'Report URL available' : 'No file attached', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            if (fileUrl.isNotEmpty)
              SelectableText(
                fileUrl,
                maxLines: 5,
                style: const TextStyle(fontSize: 13),
              ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
            if (fileUrl.isNotEmpty)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: fileUrl));
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report link copied to clipboard')));
                },
                child: const Text('Copy Link'),
              ),
          ],
        );
      },
    );
  }

  Widget _doctorNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardStyle(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Doctor Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        Text('• Maintain hydration\n• Avoid high-sodium foods\n• Mild exercise allowed\n• Next blood test in 2 weeks', style: TextStyle(fontSize: 14, color: Colors.grey[700])),

      ]),
    );
  }

  // -----------------------
  // Due date picker
  // -----------------------

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);

      // 🔥 Persist to Firestore
      await _db.collection('users').doc(uid).update({
        'dueDate': Timestamp.fromDate(picked),
      });
    }
  }

}
