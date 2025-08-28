import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/views/splash_screen.dart';

// Fungsi main sekarang menjadi async untuk menunggu inisialisasi Supabase
Future<void> main() async {
  // Pastikan semua widget siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  // Ganti URL dan Anon Key sesuai dengan proyek Supabase Anda
  await Supabase.initialize(
    url: 'https://kpraenmxxgyrzrgufbwk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwcmFlbm14eGd5cnpyZ3VmYndrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODkxNjAsImV4cCI6MjA3MTg2NTE2MH0.cr-o9S9FFnkYumHPNh6oIvyxSWB5-BsfJdpw9LUWTcM',
  );

  runApp(const MyApp());
}

// Membuat instance Supabase client yang bisa diakses dari mana saja di aplikasi
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesit TBC',
      // Menonaktifkan banner debug di pojok kanan atas
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Anda bisa menyesuaikan tema warna aplikasi di sini
        primarySwatch: Colors.teal,
        // Menggunakan font yang lebih modern jika tersedia
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Tema untuk button agar sesuai desain
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17a2b8), // Warna Teal/Cyan
              foregroundColor: Colors.white, // Warna teks
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              )
          ),
        ),
      ),
      // Halaman pertama yang akan dibuka adalah SplashScreen
      // SplashScreen akan mengecek status login dan mengarahkan ke halaman yang sesuai
      home: const SplashScreen(),
    );
  }
}