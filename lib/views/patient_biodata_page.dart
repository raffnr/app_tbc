import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:app_tbc/views/symptom_check_page.dart';

class PatientBiodataPage extends StatefulWidget {
  const PatientBiodataPage({super.key});

  @override
  State<PatientBiodataPage> createState() => _PatientBiodataPageState();
}

class _PatientBiodataPageState extends State<PatientBiodataPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap field
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Variabel state
  String? _selectedGender;
  DateTime? _selectedDate;
  File? _imageFile;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Menampilkan date picker untuk memilih tanggal
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

  /// Memilih gambar dari galeri perangkat
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  /// Memvalidasi data dan meneruskannya ke halaman pengecekan gejala
  void _startSymptomCheck() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih jenis kelamin.')),
      );
      return;
    }

    // Siapkan data biodata dalam sebuah Map untuk dikirim ke halaman selanjutnya
    final biodata = {
      'nik': _nikController.text.trim(),
      'full_name': _nameController.text.trim(),
      'gender': _selectedGender,
      'date_of_birth': _selectedDate?.toIso8601String(),
      'address': _addressController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'image_file': _imageFile, // Kirim objek File-nya juga
    };

    // Navigasi ke halaman pertanyaan gejala sambil membawa data biodata
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SymptomCheckPage(biodata: biodata),
      ),
    );
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
            const Text('Biodata Pasien', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildTextFormField(controller: _nikController, hintText: 'Masukkan NIK', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _nameController, hintText: 'Masukkan Nama Lengkap'),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Pilih Jenis Kelamin'),
              items: ['Laki-laki', 'Perempuan']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (value) => value == null ? 'Jenis kelamin tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _dobController,
              decoration: _inputDecoration('Pilih Tanggal Lahir').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined)
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) => (value == null || value.isEmpty) ? 'Tanggal lahir tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(controller: _addressController, hintText: 'Masukan Alamat'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _phoneController, hintText: 'Masukan No Telepon', keyboardType: TextInputType.phone),
            const SizedBox(height: 24),

            const Text('Lampirkan Foto Pasien (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_imageFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_imageFile!.path.split('/').last, overflow: TextOverflow.ellipsis)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _imageFile = null)),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17a2b8).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF17a2b8), style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 40, color: Color(0xFF17a2b8)),
                      SizedBox(height: 8),
                      Text('Pilih foto dari galeri', style: TextStyle(color: Color(0xFF17a2b8))),
                      Text('Max size: 5 MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startSymptomCheck,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17a2b8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mulai Pengecekan'),
            )
          ],
        ),
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