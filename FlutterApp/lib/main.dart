import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/AppFunction/global_variables.dart';
import 'package:flutter_app/widgets/navigation_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'AppFunction/mqtt_manager.dart';
import 'pages/home_page.dart';
import 'pages/light_control_page.dart';
import 'pages/lighting_schedule_page.dart';
import 'pages/security_cameras_page.dart';
import 'pages/advertisement_schedule_page.dart';
import 'pages/environmental_sensors_page.dart';
import 'pages/historical_data_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MqttManager(); // Initialize MQTT Manager
    global_databaseReference = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DATABASE_URL,
    ).ref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: const Color(0xFFF9F9F9),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    HomePage(),
    LightControlPage(),
    LightingSchedulePage(),
    SecurityCamerasPage(),
    AdvertisementSchedulePage(),
    EnvironmentalSensorsPage(),
    HistoricalDataPage(),
    HomePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Expanded(
                  flex: 126,
                  child: SizedBox(), // Replace this with your desired widget
                ),
                Expanded(
                  flex: 889,
                  child: Container(
                    // Margin = navigation drawer before expanding 103 + padding 40
                    margin: const EdgeInsets.only(left: 143, right: 10, top: 0 , bottom: 10),
                    // Add border radius everywhere = drawer border radius = 31 for child: _pages.elementAt(_selectedIndex),
                    child: Container(
                      //border with color #E6E5F2 width 10
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31),
                        border: Border.all(color: Color(0xFFE6E5F2), width: 2),

                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(31),
                        child: _pages.elementAt(_selectedIndex),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: CustomNavigationDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  //Icon settings white with black stroke
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Add your settings page navigation here
                  },
                ),
                SizedBox(width: 23),
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    // Add your notifications page navigation here
                  },
                ),
                SizedBox(width: 23),
                // Logo with rounded border corner white background and black stroke total width of Container = 35
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Image.asset('lib/assets/icons/Logo-DH-Bach-Khoa-HCMUT.png', height: 25),
                ),
                SizedBox(width: 23),
                Container(
                  // CSE, BOLD
                  child: Text('CSE',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
                SizedBox(width: 38)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
