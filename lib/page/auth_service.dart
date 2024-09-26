import 'package:shared_preferences/shared_preferences.dart';

// ฟังก์ชันสำหรับดึง Access Token จาก Shared Preferences
Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken'); // ดึงค่า accessToken ที่เคยเก็บไว้
}