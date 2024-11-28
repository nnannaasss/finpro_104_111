import 'package:final_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:final_project/reusable_widget/reusable_widget.dart';
import 'package:final_project/pages/signup_page.dart';
import 'package:hive/hive.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  // State untuk kontrol visibilitas password
  bool _isPasswordVisible = false;

  // Fungsi untuk login menggunakan Hive
  Future<bool> signInWithHive(BuildContext context, String email, String password) async {
    final box = await Hive.openBox('Signin'); // Membuka box Hive

    // Cek apakah email ada di database
    if (box.containsKey(email)) {
      // Ambil data pengguna yang disimpan
      var userData = box.get(email);

      // Validasi apakah userData berupa Map
      if (userData is Map && userData['password'] == password) {
        print('Login successful for user: ${userData['username']}'); // Debugging
        return true; // Login berhasil
      } else {
        print('Invalid password'); // Debugging
      }
    } else {
      print('Email not found'); // Debugging
    }

    // Jika gagal login, tampilkan pesan error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid email or password")),
    );
    return false; // Login gagal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 66, 97),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField("Enter Email", Icons.person_outline, false, _emailTextController),
                const SizedBox(height: 20),
                // Menambahkan TextField untuk password, dengan visibilitas
                TextField(
                  controller: _passwordTextController,
                  obscureText: !_isPasswordVisible, // Menyembunyikan atau menampilkan password
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    // Bagian ini tidak diubah, tetap mempertahankan warna asli
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueGrey, width: 1.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                signInSignUpButton(context, true, () async {
                  // Gunakan fungsi signInWithHive dan periksa hasilnya
                  bool success = await signInWithHive(
                    context,
                    _emailTextController.text.trim(),
                    _passwordTextController.text.trim(),
                  );
                  if (success) {
                    // Jika berhasil sign in, navigasi ke HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(email: _emailTextController.text.trim())),
                    );
                  }
                }),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't Have account?", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
