import 'package:flutter/material.dart';

class CampDetailScreen extends StatelessWidget {
  final Map<String, dynamic> camp;

  CampDetailScreen({required this.camp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(camp['name']),
        backgroundColor: Color.fromARGB(248, 226, 131, 53),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนปกของค่ายมวย (Banner)
            Stack(
              children: [
                // รูปภาพปก
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        camp['banner_image'] ?? 'https://via.placeholder.com/800x200',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: MediaQuery.of(context).size.width * 0.5 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      camp['profile_image'] ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      camp['name'],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      camp['description'] ?? 'ไม่มีคำอธิบาย',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    'ตำแหน่งที่ตั้ง:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ละติจูด: ${camp['location']['latitude']}',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Text(
                    'ลองจิจูด: ${camp['location']['longitude']}',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text(
                    'อัปเดตเมื่อ: ${camp['updated_at']}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  
                  SizedBox(height: 20),

                  // กล่อง 4 เหลี่ยม มุมโค้ง นูน
                  _buildCustomBox('นักมวย', Color(0xFFFED673)),
                  SizedBox(height: 20),
                  _buildCustomBox('ครูมวย', Color(0xFFFED673)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBox(String title, Color boxColor) {
    return Container(
      width: double.infinity, // กำหนดความกว้างให้เต็มพื้นที่
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center( // จัดกลางข้อความ
        child: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
