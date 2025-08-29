import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_tbc/main.dart';

class PatientEditPage extends StatefulWidget {
  final Map<String, dynamic> patient;
  const PatientEditPage({super.key, required this.patient});

  @override
  State<PatientEditPage> createState() => _PatientEditPageState();
}

class _PatientEditPageState extends State<PatientEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers untuk setiap field
  late TextEditingController _nikController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  // Variabel state
  String? _selectedGender;
  DateTime? _selectedDate;
  File? _newImageFile;
  String? _existingImageUrl;
  final _imagePicker = ImagePicker();

  // Variabel untuk jawaban gejala
  final Map<String, String?> _answers = {};
  final List<String> _questions = [
    'Batuk lebih dari 2 minggu?',
    'Batuk berdahak darah?',
    'Sesak napas/nyeri dada?',
    'Demam tidak sembuh-sembuh?',
    'Keringat malam berlebih?',
    'Berat badan turun tanpa sebab?',
    'Mudah lelah/lemas?',
  ];
  final List<String> _questionKeys = [
    'symptom_cough_more_than_2_weeks',
    'symptom_cough_with_blood',
    'symptom_shortness_of_breath',
    'symptom_fever',
    'symptom_night_sweats',
    'symptom_weight_loss',
    'symptom_fatigue',
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua controller dan state dengan data pasien yang ada
    _nameController = TextEditingController(text: widget.patient['full_name']);
    _nikController = TextEditingController(text: widget.patient['nik']);
    _addressController = TextEditingController(text: widget.patient['address']);
    _phoneController = TextEditingController(text: widget.patient['phone_number']);
    _dobController = TextEditingController();

    _selectedGender = widget.patient['gender'];
    _existingImageUrl = widget.patient['photo_url'];

    if (widget.patient['date_of_birth'] != null) {
      _selectedDate = DateTime.parse(widget.patient['date_of_birth']);
      _dobController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!);
    }

    // Inisialisasi jawaban gejala dari data boolean
    for (int i = 0; i < _questions.length; i++) {
      final key = _questionKeys[i];
      final question = _questions[i];
      final hasSymptom = widget.patient[key] ?? false;
      _answers[question] = hasSymptom ? 'Ya' : 'Tidak';
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _newImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  /// Fungsi untuk mengirim pembaruan data ke Supabase
  Future<void> _updatePatientData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String? imageUrl = _existingImageUrl;

      // 1. Jika ada gambar baru, upload dan dapatkan URL-nya
      if (_newImageFile != null) {
        final userId = supabase.auth.currentUser!.id;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '$userId/$fileName';

        await supabase.storage
            .from('patient_photos')
            .upload(filePath, _newImageFile!, fileOptions: const FileOptions(contentType: 'image/jpeg'));

        imageUrl = supabase.storage.from('patient_photos').getPublicUrl(filePath);
      }

      // 2. Siapkan data yang akan diupdate
      final dataToUpdate = {
        'nik': _nikController.text.trim(),
        'full_name': _nameController.text.trim(),
        'gender': _selectedGender,
        'date_of_birth': _selectedDate?.toIso8601String(),
        'address': _addressController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'photo_url': imageUrl,
        // Update jawaban gejala
        _questionKeys[0]: _answers[_questions[0]] == 'Ya',
        _questionKeys[1]: _answers[_questions[1]] == 'Ya',
        _questionKeys[2]: _answers[_questions[2]] == 'Ya',
        _questionKeys[3]: _answers[_questions[3]] == 'Ya',
        _questionKeys[4]: _answers[_questions[4]] == 'Ya',
        _questionKeys[5]: _answers[_questions[5]] == 'Ya',
        _questionKeys[6]: _answers[_questions[6]] == 'Ya',
      };

      // 3. Kirim pembaruan ke Supabase
      await supabase.from('patients').update(dataToUpdate).eq('id', widget.patient['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pasien berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $error'), backgroundColor: Colors.red),
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
        title: const Text('Edit Data Pasien', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF17a_2b8),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Bagian Foto
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _newImageFile != null
                          ? FileImage(_newImageFile!)
                          : (_existingImageUrl != null ? NetworkImage(_existingImageUrl!) : null) as ImageProvider?,
                      child: _newImageFile == null && _existingImageUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white),
                            Text('Ubah Foto', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Form Biodata ---
            const Text('Biodata Pasien', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _nameController, hintText: 'Nama Lengkap'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _nikController, hintText: 'NIK', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _addressController, hintText: 'Alamat'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _phoneController, hintText: 'No. Telp', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Pilih Jenis Kelamin'),
              items: ['Laki-laki', 'Perempuan']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              decoration: _inputDecoration('Pilih Tanggal Lahir').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined)
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),

            // --- Form Gejala ---
            const Text('Edit Hasil Skrining Gejala', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._questions.map((question) => _buildQuestionDropdown(question)).toList(),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePatientData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17a2b8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Update Data Pasien'),
            )
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

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
            decoration: _inputDecoration('Pilih Jawaban'),
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

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hintText),
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) ? '$hintText tidak boleh kosong' : null,
    );
  }
}