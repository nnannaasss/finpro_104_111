import 'dart:io';
import 'package:final_project/pages/calculator_page.dart';
import 'package:final_project/pages/sarankesan_page.dart';
import 'package:final_project/pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String email; // Email pengguna yang digunakan untuk login

  const ProfilePage({super.key, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;
  File? imageFile;
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void navigateToSignin(BuildContext context) {
    // Navigasi ke halaman login tanpa logout status login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
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
        MaterialPageRoute(builder: (context) => const ProfilePage(email: '',)),
      );
    }
  }

  Future<void> showPictureDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Action'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                getFromCamera();
                Navigator.of(context).pop();
              },
              child: const Text('Open Camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                getFromGallery();
                Navigator.of(context).pop();
              },
              child: const Text('Open Gallery'),
            ),
          ],
        );
      },
    );
  }

  // get from gallery
  getFromGallery() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // get from camera
  getFromCamera() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: Hive.openBox('Signin'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final box = snapshot.data!;
        final userData = box.get(widget.email) ?? {};
        final username = userData['username'] as String? ?? 'Unknown';

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 46, 66, 97),
          appBar: AppBar(
            title: const Text('Profile Page'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Menampilkan foto jika ada
                  Container(
                    margin: const EdgeInsets.all(20),
                    width: 150,
                    height: 150,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      color: Colors.blueGrey,
                      strokeWidth: 1,
                      dashPattern: const [5, 5],
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: imageFile != null
                              ? Image.file(File(imageFile!.path), fit: BoxFit.cover)
                              : const Icon(Icons.image_outlined, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                   // Tombol untuk memilih gambar
                  ElevatedButton(
                    onPressed: showPictureDialog,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('Change Profile Picture', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 30),
                  // Menampilkan username
                  Text(
                    username,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Menampilkan email
                  Text(
                    widget.email,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      navigateToSignin(context); // Pindah ke halaman login
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 46, 66, 97),
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('Logout', style: TextStyle(color: Colors.white)),
                  ),
                  /*const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/foto.jpg'),
                    ),
                  ),
                  const SizedBox(height: 20),*/
                  
                  
                 
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: const Color.fromARGB(255, 46, 66, 97),
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
      },
    );
  }
}
