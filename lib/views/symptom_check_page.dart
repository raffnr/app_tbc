import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/main.dart';

class SymptomCheckPage extends StatefulWidget {
  final Map<String, dynamic> biodata;

  const SymptomCheckPage({super.key, required this.biodata});

  @override
  State<SymptomCheckPage> createState() => _SymptomCheckPageState();
}

class _SymptomCheckPageState extends State<SymptomCheckPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // List pertanyaan
  final List<String> _questions = [
    'Batuk lebih dari 2 minggu?',
    'Batuk berdahak darah?',
    'Sesak napas/nyeri dada?',
    'Demam tidak sembuh-sembuh?',
    'Keringat malam berlebih?',
    'Berat badan turun tanpa sebab?',
    'Mudah lelah/lemas?',
  ];

  // Map untuk menyimpan jawaban (Pertanyaan -> Jawaban)
  final Map<String, String?> _answers = {};

  /// Fungsi final untuk upload foto dan simpan semua data
  Future<void> _uploadResult() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String? imageUrl;
      final File? imageFile = widget.biodata['image_file'];
      final userId = supabase.auth.currentUser!.id;

      // 1. Upload foto jika ada
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '$userId/$fileName';
        await supabase.storage
            .from('patient_photos')
            .upload(filePath, imageFile, fileOptions: const FileOptions(contentType: 'image/jpeg'));
        imageUrl = supabase.storage.from('patient_photos').getPublicUrl(filePath);
      }

      // 2. Gabungkan biodata dengan jawaban gejala
      final finalData = {
        ...widget.biodata, // Ambil semua data dari biodata
        'photo_url': imageUrl,
        'created_by': userId,
        // Konversi jawaban Ya/Tidak menjadi true/false
        'symptom_cough_more_than_2_weeks': _answers[_questions[0]] == 'Ya',
        'symptom_cough_with_blood': _answers[_questions[1]] == 'Ya',
        'symptom_shortness_of_breath': _answers[_questions[2]] == 'Ya',
        'symptom_fever': _answers[_questions[3]] == 'Ya',
        'symptom_night_sweats': _answers[_questions[4]] == 'Ya',
        'symptom_weight_loss': _answers[_questions[5]] == 'Ya',
        'symptom_fatigue': _answers[_questions[6]] == 'Ya',
      };
      finalData.remove('image_file'); // Hapus file dari data akhir

      // 3. Simpan ke database
      await supabase.from('patients').insert(finalData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diunggah!'), backgroundColor: Colors.green),
        );
        // Kembali ke halaman beranda
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelaporan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF17a2b8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Daftar Pertanyaan & Pelaporan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            // Gunakan map untuk membuat daftar pertanyaan secara dinamis
            ..._questions.map((question) => _buildQuestionDropdown(question)).toList(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17a2b8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Upload Hasil'),
            )
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat pertanyaan dan dropdown
  Widget _buildQuestionDropdown(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _answers[question],
            decoration: InputDecoration(
              hintText: 'Pilih Jawaban',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: ['Ya', 'Tidak']
                .map((label) => DropdownMenuItem(child: Text(label), value: label))
                .toList(),
            onChanged: (value) {
              setState(() {
                _answers[question] = value;
              });
            },
            validator: (value) => value == null ? 'Pertanyaan ini harus dijawab' : null,
          ),
        ],
      ),
    );
  }
}