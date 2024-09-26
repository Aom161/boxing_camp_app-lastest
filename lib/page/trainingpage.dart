import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityFormPage extends StatefulWidget {
  final String? username;

  const ActivityFormPage({super.key, this.username});
  @override
  _ActivityFormPageState createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  late String? username;
  String accessToken = "";
  String refreshToken = "";
  String role = "";
  late SharedPreferences logindata;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    getInitialize();
  }

  void getInitialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCheckingStatus = prefs.getBool("isLoggedIn")!;
      username = prefs.getString("username");
      accessToken = prefs.getString("accessToken")!;
      refreshToken = prefs.getString("refreshToken")!;
      role = prefs.getString("role")!;
    });

    print(_isCheckingStatus);
    print(username);
    print(accessToken);
    print(refreshToken);
    print(role);
  }

  final TextEditingController runningDistanceController =
      TextEditingController();

  final TextEditingController ropeJumpingCountController =
      TextEditingController();
  final TextEditingController punchingCountController = TextEditingController();
  final TextEditingController weightTrainingCountController =
      TextEditingController();

  DateTime? runningStartTime;
  DateTime? runningEndTime;
  int runningDuration = 0;

  DateTime? ropeJumpingStartTime;
  DateTime? ropeJumpingEndTime;
  int ropeJumpingDuration = 0;

  DateTime? punchingStartTime;
  DateTime? punchingEndTime;
  int punchingDuration = 0;

  DateTime? weightTrainingStartTime;
  DateTime? weightTrainingEndTime;
  int weightTrainingDuration = 0;

  Future<void> _selectTime(BuildContext context, DateTime? initialTime,
      Function(DateTime) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime != null
          ? TimeOfDay.fromDateTime(initialTime)
          : TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        picked.hour,
        picked.minute,
      ));
    }
  }

  void _calculateDuration(
      DateTime? startTime, DateTime? endTime, Function(int) setDuration) {
    if (startTime != null && endTime != null) {
      final duration = endTime.difference(startTime).inMinutes;
      setDuration(duration);
    }
  }

// ฟังก์ชันในการส่งข้อมูลไปยังเซิร์ฟเวอร์
  Future<void> submitActivity() async {
    final runningDistance =
        double.tryParse(runningDistanceController.text) ?? 0.0;
    final ropeJumpingCount = int.tryParse(ropeJumpingCountController.text) ?? 0;
    final punchingCount = int.tryParse(punchingCountController.text) ?? 0;
    final weightTrainingCount =
        int.tryParse(weightTrainingCountController.text) ?? 0;

    final activityData = {
      'username': username,
      'running': {
        'start_time': runningStartTime?.toIso8601String(),
        'end_time': runningEndTime?.toIso8601String(),
        'duration': runningDuration,
        'distance': runningDistance,
      },
      'ropeJumping': {
        'start_time': ropeJumpingStartTime?.toIso8601String(),
        'end_time': ropeJumpingEndTime?.toIso8601String(),
        'duration': ropeJumpingDuration,
        'count': ropeJumpingCount,
      },
      'punching': {
        'start_time': punchingStartTime?.toIso8601String(),
        'end_time': punchingEndTime?.toIso8601String(),
        'duration': punchingDuration,
        'count': punchingCount,
      },
      'weightTraining': {
        'start_time': weightTrainingStartTime?.toIso8601String(),
        'end_time': weightTrainingEndTime?.toIso8601String(),
        'duration': weightTrainingDuration,
        'count': weightTrainingCount,
      }
    };

    final url = Uri.parse('http://localhost:3000/addtraining');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(activityData),
      );

      if (response.statusCode == 200) {
        print('Training data submitted successfully');
      } else {
        print(
            'Failed to submit training data. Status code: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // แสดงผล response body เพื่อดูรายละเอียดของข้อผิดพลาด
      }
    } catch (error) {
      print('Error submitting training data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'บันทึกกิจกรรมรายวัน',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 10,
        backgroundColor: Color.fromARGB(248, 226, 131, 53),
        actions: [
          if (username != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '$username',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActivityForm(
              context,
              title: 'วิ่ง',
              startTime: runningStartTime,
              endTime: runningEndTime,
              duration: runningDuration,
              onSelectStartTime: (time) {
                setState(() {
                  runningStartTime = time;
                  _calculateDuration(runningStartTime, runningEndTime,
                      (d) => runningDuration = d);
                });
              },
              onSelectEndTime: (time) {
                setState(() {
                  runningEndTime = time;
                  _calculateDuration(runningStartTime, runningEndTime,
                      (d) => runningDuration = d);
                });
              },
              distanceController: runningDistanceController,
            ),
            SizedBox(height: 16),
            _buildActivityFormWithCount(
              context,
              title: 'กระโดดเชือก',
              startTime: ropeJumpingStartTime,
              endTime: ropeJumpingEndTime,
              duration: ropeJumpingDuration,
              countController: ropeJumpingCountController,
              onSelectStartTime: (time) {
                setState(() {
                  ropeJumpingStartTime = time;
                  _calculateDuration(ropeJumpingStartTime, ropeJumpingEndTime,
                      (d) => ropeJumpingDuration = d);
                });
              },
              onSelectEndTime: (time) {
                setState(() {
                  ropeJumpingEndTime = time;
                  _calculateDuration(ropeJumpingStartTime, ropeJumpingEndTime,
                      (d) => ropeJumpingDuration = d);
                });
              },
            ),
            SizedBox(height: 16),
            _buildActivityFormWithCount(
              context,
              title: 'การชกกระสอบทราย',
              startTime: punchingStartTime,
              endTime: punchingEndTime,
              duration: punchingDuration,
              countController: punchingCountController,
              onSelectStartTime: (time) {
                setState(() {
                  punchingStartTime = time;
                  _calculateDuration(punchingStartTime, punchingEndTime,
                      (d) => punchingDuration = d);
                });
              },
              onSelectEndTime: (time) {
                setState(() {
                  punchingEndTime = time;
                  _calculateDuration(punchingStartTime, punchingEndTime,
                      (d) => punchingDuration = d);
                });
              },
            ),
            SizedBox(height: 16),
            _buildActivityFormWithCount(
              context,
              title: 'ยกน้ำหนัก',
              startTime: weightTrainingStartTime,
              endTime: weightTrainingEndTime,
              duration: weightTrainingDuration,
              countController: weightTrainingCountController,
              onSelectStartTime: (time) {
                setState(() {
                  weightTrainingStartTime = time;
                  _calculateDuration(weightTrainingStartTime,
                      weightTrainingEndTime, (d) => weightTrainingDuration = d);
                });
              },
              onSelectEndTime: (time) {
                setState(() {
                  weightTrainingEndTime = time;
                  _calculateDuration(weightTrainingStartTime,
                      weightTrainingEndTime, (d) => weightTrainingDuration = d);
                });
              },
            ),
            SizedBox(height: 24),
           ElevatedButton(
              onPressed: submitActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 97, 203, 5), // กำหนดสีปุ่ม
              ),
              child: const Text('บันทึกกิจกรรม',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0, // กำหนดขนาดตัวอักษรที่นี่
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  // Reusable function to build each activity form
  Widget _buildActivityForm(
    BuildContext context, {
    required String title,
    required DateTime? startTime,
    required DateTime? endTime,
    required int duration,
    required Function(DateTime) onSelectStartTime,
    required Function(DateTime) onSelectEndTime,
    TextEditingController? distanceController,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                  'เวลาเริ่มซ้อม: ${startTime != null ? DateFormat('HH:mm').format(startTime) : 'ยังไม่ได้เลือกเวลา'}'),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context, startTime, onSelectStartTime),
            ),
            ListTile(
              title: Text(
                  'เวลาสิ้นสุดการซ้อม: ${endTime != null ? DateFormat('HH:mm').format(endTime) : 'ยังไม่ได้เลือกเวลา'}'),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context, endTime, onSelectEndTime),
            ),
            SizedBox(height: 8),
            if (distanceController != null)
              TextField(
                controller: distanceController,
                decoration: InputDecoration(
                  labelText: 'ระยะทาง (กิโลเมตร)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 8),
            Text(
              'ระยะเวลาที่ซ้อม: $duration นาที',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable function to build activity forms that include count
  Widget _buildActivityFormWithCount(
    BuildContext context, {
    required String title,
    required DateTime? startTime,
    required DateTime? endTime,
    required int duration,
    required TextEditingController countController,
    required Function(DateTime) onSelectStartTime,
    required Function(DateTime) onSelectEndTime,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                  'เวลาเริ่มซ้อม: ${startTime != null ? DateFormat('HH:mm').format(startTime) : 'ยังไม่ได้เลือกเวลา'}'),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context, startTime, onSelectStartTime),
            ),
            ListTile(
              title: Text(
                  'เวลาสิ้นสุดการซ้อม: ${endTime != null ? DateFormat('HH:mm').format(endTime) : 'ยังไม่ได้เลือกเวลา'}'),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context, endTime, onSelectEndTime),
            ),
            SizedBox(height: 8),
            TextField(
              controller: countController,
              decoration: InputDecoration(
                labelText: 'จำนวนครั้งที่ทำได้',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Text(
              'ระยะเวลาที่ซ้อม: $duration นาที',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
