import 'dart:convert';
import 'package:boxing_camp_app/main.dart';
import 'package:boxing_camp_app/page/campdetail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000/getcamp';

  Future<List<dynamic>> fetchCamps() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load camps');
    }
  }
}

class CampsScreen extends StatelessWidget {
  final String? username;

  CampsScreen({super.key, this.username});

  final ApiService apiService = ApiService();
  Future<List<dynamic>> _fetchCamps() async {
    return await apiService.fetchCamps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ค่ายมวย',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
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
                  'ยินดีต้อนรับคุณ $username',
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
      drawer: BaseAppDrawer(
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
      body: FutureBuilder<List<dynamic>>(
        future: _fetchCamps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ไม่มีค่ายมวย'));
          } else {
            final camps = snapshot.data!;
            return ListView.builder(
              itemCount: camps.length,
              itemBuilder: (context, index) {
                final camp = camps[index];

                // ตรวจสอบค่า 'image_url' และ 'name' ก่อนการใช้งาน
                final imageUrl = camp['image_url'] ?? 'https://via.placeholder.com/150'; // ใช้ภาพเริ่มต้นหากไม่มีข้อมูล
                final campName = camp['name'] ?? 'ไม่มีชื่อค่าย';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      // นำทางไปยังหน้ารายละเอียดค่ายมวยเมื่อกด
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampDetailScreen(camp: camp),
                        ),
                      );
                    },
                    child: Container(
                      height: 300, // เพิ่มความสูงของกล่อง
                      decoration: BoxDecoration(
                        color: Color(0xFFFED673), // สีของกล่องที่เปลี่ยนเป็น #FED673
                        borderRadius: BorderRadius.circular(20), // มุมโค้งของกล่อง
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // สีเงา
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // การเลื่อนตำแหน่งของเงา
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20.0), // เพิ่ม padding ภายในกล่อง
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // จัดวางให้ตรงกลาง
                        children: [
                          // แสดงรูปภาพของค่าย
                          Image.network(
                            imageUrl, // ใช้ URL รูปภาพที่ได้รับ หรือภาพเริ่มต้น
                            height: 150.0, // ขนาดความสูงของรูปภาพใหญ่ขึ้น
                            width: 150.0,  // ขนาดความกว้างของรูปภาพใหญ่ขึ้น
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 16), // เพิ่มระยะห่างระหว่างรูปกับข้อความ
                          // แสดงชื่อของค่าย
                          Text(
                            campName, // ใช้ชื่อที่ได้รับหรือข้อความเริ่มต้น
                            style: TextStyle(
                              fontSize: 22, // ขนาดตัวอักษรใหญ่ขึ้น
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // ปุ่มลอยสำหรับเพิ่มค่ายมวย
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // นำทางไปยังหน้าสำหรับเพิ่มค่ายมวยใหม่
          Navigator.pushNamed(context, '/addCamp'); // กำหนดเส้นทางไปยังหน้าสำหรับเพิ่มค่ายมวย
        },
        backgroundColor: Colors.green, // สีเขียวสำหรับปุ่ม
        child: Icon(Icons.add, color: Colors.white), // ไอคอนเครื่องหมายบวก
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // ตำแหน่งของปุ่มลอยที่มุมขวาล่าง
    );
  }
}
