import 'package:flutter/material.dart';
import 'package:app_tbc/main.dart'; // Untuk mengakses client supabase global
import 'package:app_tbc/views/home_page.dart'; // Halaman utama setelah login
import 'package:app_tbc/views/login_page.dart'; // Halaman login jika belum ada sesi

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi redirect setelah frame pertama selesai di-render
    // Ini mencegah error navigasi saat widget tree sedang dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    // Memberi sedikit jeda agar splash screen terlihat sejenak
    await Future.delayed(const Duration(seconds: 2));

    // Cek apakah widget masih ada di tree (best practice)
    if (!mounted) return;

    // Mengambil sesi login saat ini dari Supabase
    final session = supabase.auth.currentSession;

    if (session != null) {
      // Jika ada sesi (sudah login), arahkan ke HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Jika tidak ada sesi (belum login), arahkan ke LoginPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan logo Anda
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 16),
            // Tampilkan nama aplikasi
            const Text(
              'Gesit TBC',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF008080), // Warna Teal
              ),
            ),
            const SizedBox(height: 48),
            // Indikator loading
            const CircularProgressIndicator(
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}// TODO Implement this library.