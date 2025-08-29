import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_tbc/main.dart';

class PatientDetailPage extends StatefulWidget {
  final int patientId;
  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  late Future<Map<String, dynamic>> _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = _fetchPatientDetails();
  }

  /// Mengambil data lengkap satu pasien dari Supabase
  Future<Map<String, dynamic>> _fetchPatientDetails() async {
    final response = await supabase
        .from('patients')
        .select()
        .eq('id', widget.patientId)
        .single();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pasien', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF17a2b8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Gunakan FutureBuilder untuk menampilkan data setelah berhasil diambil
      body: FutureBuilder<Map<String, dynamic>>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data pasien tidak ditemukan.'));
          }

          final patient = snapshot.data!;
          // Format tanggal agar mudah dibaca
          final formattedDob = patient['date_of_birth'] != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(patient['date_of_birth']))
              : 'Tidak ada data';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Foto Pasien
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: patient['photo_url'] != null
                      ? Image.network(
                    patient['photo_url'],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 150,
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 150, color: Colors.grey),
                  )
                      : const Icon(Icons.person, size: 150, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Biodata
              _buildInfoCard('Nama Lengkap', patient['full_name'] ?? 'Tidak ada data'),
              _buildInfoCard('NIK', patient['nik'] ?? 'Tidak ada data'),
              _buildInfoCard('Jenis Kelamin', patient['gender'] ?? 'Tidak ada data'),
              _buildInfoCard('Tanggal Lahir', formattedDob),
              _buildInfoCard('Alamat', patient['address'] ?? 'Tidak ada data'),
              _buildInfoCard('No. Telp', patient['phone_number'] ?? 'Tidak ada data'),

              const SizedBox(height: 24),
              const Text(
                'Hasil Skrining Gejala',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),

              // Jawaban Gejala
              _buildSymptomRow('Batuk lebih dari 2 minggu?', patient['symptom_cough_more_than_2_weeks'] ?? false),
              _buildSymptomRow('Batuk berdahak darah?', patient['symptom_cough_with_blood'] ?? false),
              _buildSymptomRow('Sesak napas/nyeri dada?', patient['symptom_shortness_of_breath'] ?? false),
              _buildSymptomRow('Demam tidak sembuh-sembuh?', patient['symptom_fever'] ?? false),
              _buildSymptomRow('Keringat malam berlebih?', patient['symptom_night_sweats'] ?? false),
              _buildSymptomRow('Berat badan turun tanpa sebab?', patient['symptom_weight_loss'] ?? false),
              _buildSymptomRow('Mudah lelah/lemas?', patient['symptom_fatigue'] ?? false),
            ],
          );
        },
      ),
    );
  }

  /// Helper widget untuk membuat kartu informasi biodata
  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget untuk menampilkan baris pertanyaan dan jawaban gejala
  Widget _buildSymptomRow(String question, bool hasSymptom) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question, style: const TextStyle(fontSize: 15))),
          Text(
            hasSymptom ? 'Ya' : 'Tidak',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: hasSymptom ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}