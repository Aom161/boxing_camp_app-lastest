import 'dart:io'; // สำหรับการใช้ไฟล์ที่เลือกจากอุปกรณ์
import 'package:boxing_camp_app/main.dart';
import 'package:boxing_camp_app/page/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // สำหรับ ImagePicker
import 'dart:convert'; // สำหรับการ decode JSON

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? username;
  String accessToken = "";
  String refreshToken = "";
  String role = "";
  String phoneNumber = ""; // ฟิลด์สำหรับเก็บเบอร์โทรศัพท์
  String address = ""; // ฟิลด์สำหรับเก็บที่อยู่
  late SharedPreferences logindata;
  bool _isCheckingStatus = false;
  File? _image; // สำหรับเก็บรูปที่เลือก

  @override
  void initState() {
    super.initState();
    username = widget.username;
    getInitialize();
    _loadUserData(); // เรียกฟังก์ชันเพื่อโหลดข้อมูลผู้ใช้
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
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Assume you stored token after login

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/user'), // แก้ไข URL ให้ถูกต้อง
        headers: {
          'Authorization': 'Bearer $token', // ส่ง token ไปยัง API
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // แปลง response เป็น JSON
        setState(() {
          username = data['username'] ?? 'ไม่มีชื่อผู้ใช้';
          phoneNumber = data['phoneNumber'] ?? 'ไม่มีเบอร์โทร'; // เก็บเบอร์โทรศัพท์
          address = data['address'] ?? 'ไม่มีที่อยู่'; // เก็บที่อยู่
        });
      } else {
        // กรณีที่ API เกิดข้อผิดพลาด
        print('Error fetching user data: ${response.statusCode}');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // เก็บรูปที่เลือกใน _image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'โปรไฟล์ของฉัน',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Color.fromARGB(248, 226, 131, 53),
      ),
      drawer: BaseAppDrawer(
        username: username,
        isLoggedIn: _isCheckingStatus,
        role: role,
        onHomeTap: (context) {
          Navigator.pushNamed(context, '/home');
        },
        onCampTap: (context) {
          Navigator.pushNamed(context, '/dashboard');
        },
        onContactTap: (context) {
          Navigator.pushNamed(context, '/contact');
        },
      ),
      body: SingleChildScrollView( // ทำให้หน้าเลื่อนได้
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5, // ครึ่งหน้าจอแนวตั้ง
                  width: double.infinity, // เต็มความกว้างของหน้าจอ
                  color: Color(0xFFFED673), // สี FED673
                ),
                GestureDetector(
                  onTap: _pickImage, // เมื่อกดที่วงกลมจะเปิด ImagePicker
                  child: CircleAvatar(
                    radius: 120, // ขนาดวงกลม
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 60, // เพิ่มขนาดไอคอนกล้องให้ใหญ่ขึ้น
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center, // จัดข้อความให้อยู่ตรงกลาง
              child: Text(
                username ?? 'ไม่มีชื่อผู้ใช้',
                style: TextStyle(
                  fontSize: 24, // ขนาดฟอนต์ใหญ่ขึ้น
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่าง
            Container(
              height: MediaQuery.of(context).size.height * 0.3, // 30% ของความสูงหน้าจอ
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFED673), 
                borderRadius: BorderRadius.circular(30), // ขอบโค้งมน
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10, // ทำให้นูนขึ้น
                    offset: Offset(0, 3), // เงาเล็กน้อยทางแนวดิ่ง
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10), // ขยับไอคอนลงมานิดนึง
                    Row(
                      children: [
                        SizedBox(width: 20), // ขยับไปทางขวา
                        Icon(
                          Icons.phone, // ไอคอนโทรศัพท์
                          color: Colors.black,
                          size: 24, // ขนาดไอคอน
                        ),
                        SizedBox(width: 10), // เพิ่มช่องว่างระหว่างไอคอนกับข้อความ
                        Expanded(
                          child: Text(
                            phoneNumber, // แสดงเบอร์โทรศัพท์ที่ดึงมาจากฐานข้อมูล
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // เพิ่มความหนาของข้อความ
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20), // เพิ่มระยะห่างระหว่างไอคอนกับที่อยู่
                    Row(
                      children: [
                        SizedBox(width: 20), // ขยับไปทางขวา
                        Icon(
                          Icons.location_on, // ไอคอนที่อยู่
                          color: Colors.black,
                          size: 24, // ขนาดไอคอน
                        ),
                        SizedBox(width: 10), // เพิ่มช่องว่างระหว่างไอคอนกับข้อความ
                        Expanded(
                          child: Text(
                            address, // แสดงที่อยู่ที่ดึงมาจากฐานข้อมูล
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // เพิ่มความหนาของข้อความ
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5), // เพิ่มระยะห่าง
            ElevatedButton(
              onPressed: () {
                // Action for editing profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(
                      userData: {
                        'username': username,
                        'phoneNumber': phoneNumber,
                        'address': address,
                      },
                    ),
                  ),
                );
              },
              child: Text('แก้ไขโปรไฟล์'),
            ),
          ],
        ),
      ),
    );
  }
}
