import 'package:boxing_camp_app/page/addboxerpage.dart';
import 'package:boxing_camp_app/page/addboxingcamp.dart';
import 'package:boxing_camp_app/page/adminpage.dart';
import 'package:boxing_camp_app/page/boxerpage.dart';
import 'package:boxing_camp_app/page/boxeruser.dart';
import 'package:boxing_camp_app/page/campdetail.dart';
import 'package:boxing_camp_app/page/contact.dart';
import 'package:boxing_camp_app/page/dashboard.dart';
import 'package:boxing_camp_app/page/editprofile.dart';
import 'package:boxing_camp_app/page/firstpage.dart';
import 'package:boxing_camp_app/page/homepage.dart';
import 'package:boxing_camp_app/page/loginpage.dart';
import 'package:boxing_camp_app/page/managerpage.dart';
import 'package:boxing_camp_app/page/manegeruser.dart';
import 'package:boxing_camp_app/page/profilepage.dart';
import 'package:boxing_camp_app/page/showcamp.dart';
import 'package:boxing_camp_app/page/trainerpage.dart';
import 'package:boxing_camp_app/page/traineruser.dart';
import 'package:boxing_camp_app/page/traininghistory.dart';
import 'package:boxing_camp_app/page/trainingpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          String? role = snapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Boxing Camp',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(253, 173, 53, 1),
                background: const Color.fromARGB(254, 214, 115, 1),
              ),
              useMaterial3: true,
            ),
            initialRoute: role == null ? '/login' : _getInitialRoute(role),
            routes: {
              '/home': (context) => HomePage(),
              '/addCamp': (context) => AddCampPage(),
              '/getcamp': (context) => CampsScreen(),
              '/addtraining': (context) => ActivityFormPage(),
              '/profile': (context) => ProfilePage(),
              '/contact': (context) => ContactPage(),
              '/login': (context) => LoginScreen(),
              '/traininghistory': (context) => ActivityHistoryPage(),
              '/adminpage': (context) => AdminHomePage(),
              '/boxerpage': (context) => Boxerpage(),
              '/dashboard': (context) => DashboardPage(),
              '/editprofile': (context) => EditProfile(userData: {}),
              '/firstpage': (context) => Firstpage(),
              '/managerpage': (context) => ManagerHomePage(),
              '/trainer': (context) => TrainerHomePage(),
              '/addboxer': (context) => AddBoxerPage(),
              '/campDetail': (context) => CampDetailScreen(camp: {},),
              '/traineruser': (context) => Traineruser(),
              '/boxeruser': (context) => Boxeruser(),
              '/manegeruser': (context) => Manegeruser(),
            },
            home: const LoginScreen(),
          );
        }
      },
    );
  }

  Future<String?> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  String _getInitialRoute(String role) {
    if (role == 'admin') return '/adminpage';
    if (role == 'manager') return '/managerpage';
    if (role == 'trainer') return '/trainer';
    if (role == 'boxer') return '/boxerpage';
    return '/home';
  }
}

class BaseAppDrawer extends StatefulWidget {
  final String? username;
  final String? role;
  final bool? isLoggedIn;
  final Function(BuildContext) onHomeTap;
  final Function(BuildContext) onCampTap;
  final Function(BuildContext) onContactTap;

  const BaseAppDrawer({
    Key? key,
    this.username,
    this.role,
    this.isLoggedIn,
    required this.onHomeTap,
    required this.onCampTap,
    required this.onContactTap,
  }) : super(key: key);

  @override
  _BaseAppDrawerState createState() => _BaseAppDrawerState();
}

class _BaseAppDrawerState extends State<BaseAppDrawer> {
 
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            child: Image.asset(
              'assets/images/logomuay.png',
              height: 100,
            ),
          ),
          ListTile(
            title: const Text('หน้าแรก'),
            onTap: () => widget.onHomeTap(context),
          ),
          ListTile(
            title: const Text('ติดต่อเรา'),
            onTap: () => widget.onContactTap(context),
          ),
          ListTile(
            title: Text('แดชบอร์ด'),
            onTap: () => widget.onCampTap(context),
          ),
          if(widget.role! == "ผู้ดูแลระบบ") ...[
            ListTile(
              title: const Text('นักมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/boxeruser');
              },
            ),
            ListTile(
              title: const Text('ผู้จัดการค่ายมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/manegeruser');
              },
            ),
            ListTile(
              title: const Text('ครูมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/traineruser');
              },
            ),
            ListTile(
              title: const Text('ค่ายมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/getcamp');
              },
            ),
          ],
          if(widget.role! == "ผู้จัดการค่ายมวย") ...[
            ListTile(
              title: const Text('นักมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/boxeruser');
              },
            ),
            ListTile(
              title: const Text('ค่ายมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/getcamp');
              },
            ),
          ],
          if(widget.role! == "นักมวย") ...[
            ListTile(
              title: const Text('เพิ่มการฝึก'),
              onTap: () {
                Navigator.pushNamed(context, '/addtraining');
              },
            ),
            ListTile(
              title: const Text('โปรไฟล์'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              title: const Text('ประวัติการฝึกซ้อม'),
              onTap: () {
                Navigator.pushNamed(context, '/traininghistory');
              },
            ),
            ListTile(
              title: const Text('ค่ายมวย'),
              onTap: () {
                Navigator.pushNamed(context, '/getcamp');
              },
            ),
          ],
          ListTile(
            title: widget.isLoggedIn!
                ? OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red,
                        width: 3,
                      ),
                    ),
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.green,
                        width: 3,
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
