import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // BARU: Impor paket lokalisasi
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kpraenmxxgyrzrgufbwk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwcmFlbm14eGd5cnpyZ3VmYndrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODkxNjAsImV4cCI6MjA3MTg2NTE2MH0.cr-o9S9FFnkYumHPNh6oIvyxSWB5-BsfJdpw9LUWTcM',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesit TBC',
      debugShowCheckedModeBanner: false,

      // --- PENAMBAHAN KONFIGURASI LOKALISASI DI SINI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Mengatur dukungan untuk Bahasa Indonesia
        // Locale('en', 'US'), // Anda bisa menambahkan bahasa lain jika perlu
      ],
      // --------------------------------------------------

      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17a2b8),
              foregroundColor: Colors.white,
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
      home: const SplashScreen(),
    );
  }
}