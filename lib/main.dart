import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:final_project/pages/signin_page.dart';

void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: "Notification  channel for basic test",
      )
    ],
    debug: true,
  );
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();

  // Membuka box 'saranKesanBox', jika gagal beri pesan error
  try {
    await Hive.openBox('saranKesanBox');
  } catch (e) {
    print("Error membuka box: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 46, 66, 97)),
        useMaterial3: true,
      ),
      home: const SigninScreen(), // Halaman awal aplikasi
    );
  }
}
