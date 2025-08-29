import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/main.dart';
import 'package:app_tbc/views/patient_biodata_page.dart';
import 'package:app_tbc/views/patient_list_page.dart';
import 'package:app_tbc/views/login_page.dart'; // BARU: Impor untuk navigasi logout

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'Kader...';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userName = response['full_name'] ?? 'Nama Tidak Ditemukan';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _userName = 'Kader Hebat';
        });
      }
    }
  }

  // BARU: Fungsi untuk menangani logout
  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await supabase.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Gagal logout, coba lagi.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF17a2b8).withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // DIUBAH: Header dengan tombol logout
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 60),
                      const SizedBox(width: 0),
                      const Text(
                        'Gesit TBC',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003333),
                        ),
                      ),
                      const Spacer(), // Mendorong tombol ke kanan
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black, size: 28),
                        onPressed: _signOut,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Welcome Message (dan sisa UI lainnya tetap sama)
                  const Text(
                    'Selamat Datang,',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17a2b8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ayo bersama-sama berantas TBC di lingkungan kita!',
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Pilih Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Pengertian\nTBC',
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Cara\nPencegahan',
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.sick_outlined,
                        title: 'Penyebab &\nGejala TBC',
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.healing_outlined,
                        title: 'Cara\nPenanganan',
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        icon: Icons.groups_outlined,
                        title: 'Daftar\nPasien',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PatientListPage()),
                          );
                        },

                      ),
                      _buildMenuCard(
                        icon: Icons.edit_document,
                        title: 'Pelaporan',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PatientBiodataPage()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF17a2b8),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF17a2b8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}