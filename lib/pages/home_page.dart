import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:final_project/pages/sarankesan_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/carbon_service.dart';
import '../pages/calculator_page.dart';
import '../pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String email; // Tambahkan field email

  const HomePage({super.key, required this.email}); // Pastikan email diteruskan

  @override
  _CarbonHomePageState createState() => _CarbonHomePageState();
}

class _CarbonHomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final CarbonService _carbonService = CarbonService();
  Map<String, dynamic>? _carbonData;
  bool _loading = true;

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    _fetchCarbonData();
  }

  void _fetchCarbonData() async {
    try {
      final data = await _carbonService.getCarbonIntensity();
      setState(() {
        _carbonData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error fetching data: $e");
    }
  }

  triggerNotification(){
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Emisi Karbon',
        body: 'Hi! Ayo hitung emisi karbonmu hari ini!',
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalculatorPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaranKesanPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(email: widget.email), // Kirim email ke ProfilePage
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 66, 97),
      appBar: AppBar(
            title: const Text('Home'),
          ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _carbonData != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  today,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Intensitas Karbon Hari Ini:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12), // Tambahkan sedikit jarak untuk estetika
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_carbonData!["data"][0]["intensity"]["forecast"]} gCO₂/kWh',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ]
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: Text(
                            'Setiap penggunaan listrik sebesar 1 kWh akan menghasilkan emisi karbon dioksida sebesar ${_carbonData!["data"][0]["intensity"]["forecast"]} gram.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hitung Emisi Karbonmu!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CalculatorPage()),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 20, left: 20),
                                            child: Icon(Icons.electrical_services,
                                                size: 80, color: Colors.white),
                                          ),
                                          SizedBox(height: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                'Emisi Karbon Listrik',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                'Tips Mengurangi Emisi Karbon',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white54),
                                ),
                                child: const Text(
                                  '• Hemat Energi Listrik: Matikan lampu dan peralatan elektronik saat tidak digunakan, gunakan peralatan hemat energi, dan ganti bohlam dengan LED.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.black,
                                side: const BorderSide(color: Colors.white),
                              ),
                                onPressed: triggerNotification, 
                                child: const Text('Send Notification', style: TextStyle(color: Colors.white),))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    "Failed to load data",
                    style: TextStyle(color: Colors.white),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}