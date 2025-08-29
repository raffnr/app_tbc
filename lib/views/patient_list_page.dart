import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/main.dart';
import 'package:app_tbc/views/patient_detail_page.dart';
import 'package:app_tbc/views/patient_edit_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  // Menggunakan Future untuk menampung data pasien
  late Future<List<Map<String, dynamic>>> _patientFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Memuat data pertama kali saat halaman dibuka
    _patientFuture = _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fungsi untuk mengambil data pasien dari Supabase
  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    // Membangun query dasar
    var query = supabase.from('patients').select();

    // Menerapkan filter pencarian jika ada teks di kolom pencarian
    if (_searchQuery.isNotEmpty) {
      query = query.ilike('full_name', '%$_searchQuery%');
    }

    // Menjalankan query dengan urutan berdasarkan data terbaru dan mengembalikan hasilnya
    final response = await query.order('created_at', ascending: false);
    return response;
  }

  /// Fungsi yang dipanggil setiap kali teks di kolom pencarian berubah
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      // Memanggil ulang _fetchPatients untuk mendapatkan data baru sesuai query
      _patientFuture = _fetchPatients();
    });
  }

  /// Fungsi untuk menghapus data pasien
  Future<void> _deletePatient(int patientId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data pasien ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('patients').delete().eq('id', patientId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data pasien berhasil dihapus'), backgroundColor: Colors.green),
          );
          // Muat ulang daftar pasien setelah data dihapus
          setState(() {
            _patientFuture = _fetchPatients();
          });
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus data: $error'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pasien', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF17a2b8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama pasien...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
              ],
            ),
          ),
          // Menggunakan FutureBuilder untuk menampilkan daftar pasien
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _patientFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final patients = snapshot.data;
                if (patients == null || patients.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Belum ada data pasien yang Anda laporkan.'
                          : 'Pasien tidak ditemukan.',
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '${patients.length} Pasien Ditemukan',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return _buildPatientListItem(patient);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk membangun setiap item di dalam daftar
  Widget _buildPatientListItem(Map<String, dynamic> patient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Tombol Nama Pasien
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PatientDetailPage(patientId: patient['id']),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17a2b8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                patient['full_name'],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Edit
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PatientEditPage(patient: patient),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(14),
              minimumSize: const Size(50, 50),
            ),
            child: const Icon(Icons.edit),
          ),
          const SizedBox(width: 8),
          // Tombol Hapus
          ElevatedButton(
            onPressed: () => _deletePatient(patient['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(14),
              minimumSize: const Size(50, 50),
            ),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}