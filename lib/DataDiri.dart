import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Login.dart'; // pastikan file Login.dart ada

class DataDiriPage extends StatefulWidget {
  final int idUser; // ambil dari login

  const DataDiriPage({super.key, required this.idUser});

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController sekolahLainController = TextEditingController();

  String? selectedGender;
  String? selectedClass;
  String? selectedSchool;
  bool showOtherSchoolField = false;
  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    tanggalLahirController.dispose();
    sekolahLainController.dispose();
    super.dispose();
  }

  // 🔹 Helper untuk snackbar
  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSchool == "Sekolah Lainnya" &&
        sekolahLainController.text.trim().isEmpty) {
      _showSnack("Masukkan nama sekolah");
      return;
    }

    String sekolahFinal = selectedSchool == "Sekolah Lainnya"
        ? sekolahLainController.text.trim()
        : selectedSchool ?? "";

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://rekomendasiprogramstudi.com/api/datadiri.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": widget.idUser,
          "nama": namaController.text.trim(),
          "tanggal_lahir": tanggalLahirController.text.trim(),
          "jenis_kelamin": selectedGender,
          "kelas": selectedClass,
          "asal_sekolah": sekolahFinal,
        }),
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.body.isEmpty) {
        _showSnack("❌ Server tidak merespon");
        return;
      }

      final res = jsonDecode(response.body);

      if (res["status"] == "success") {
        _showSnack("✅ ${res["message"]}", success: true);

        // ✅ Arahkan ke halaman Login.dart
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      } else {
        _showSnack("❌ ${res["message"]}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showSnack("⚠️ Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03A9F4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/image/logo.png", height: 150),
                const SizedBox(height: 16),

                // === CARD FORM ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Form Data Diri",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // === Nama Lengkap ===
                        _buildTextField("Masukkan Nama Lengkap", namaController),
                        const SizedBox(height: 12),

                        // === Tanggal Lahir ===
                        TextFormField(
                          controller: tanggalLahirController,
                          readOnly: true,
                          decoration: _inputDecoration(
                            hint: "Pilih Tanggal Lahir",
                            icon: Icons.calendar_today,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2005),
                              firstDate: DateTime(1990),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              tanggalLahirController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            }
                          },
                          validator: (value) =>
                          (value == null || value.isEmpty)
                              ? "Tanggal lahir wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // === Jenis Kelamin ===
                        const Text("Pilih Jenis Kelamin"),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedGender,
                          items: ["Laki-laki", "Perempuan"],
                          onChanged: (val) =>
                              setState(() => selectedGender = val),
                          validator: (value) =>
                          value == null ? "Pilih jenis kelamin" : null,
                        ),
                        const SizedBox(height: 12),

                        // === Kelas ===
                        const Text("Pilih Kelas"),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedClass,
                          items: ["X", "XI", "XII"].map((e) => "Kelas $e").toList(),
                          onChanged: (val) =>
                              setState(() => selectedClass = val),
                          validator: (value) =>
                          value == null ? "Pilih kelas" : null,
                        ),
                        const SizedBox(height: 12),

                        // === Asal Sekolah ===
                        const Text("Pilih Asal Sekolah"),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: selectedSchool,
                          items: [
                            "SMAIT Asy Syukriyyah",
                            "SMAIT Tunas Harapan Illahi",
                            "Sekolah Lainnya",
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedSchool = val;
                              showOtherSchoolField = (val == "Sekolah Lainnya");
                            });
                          },
                          validator: (value) =>
                          value == null ? "Pilih asal sekolah" : null,
                        ),

                        if (showOtherSchoolField) ...[
                          const SizedBox(height: 12),
                          _buildTextField(
                              "Masukkan Nama Sekolah", sekolahLainController),
                        ],

                        const SizedBox(height: 20),

                        // === Tombol Lanjutkan ===
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : submitData,
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Lanjutkan",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah Punya Akun? "),
                            GestureDetector(
                              onTap: () {
                                // ✅ Arahkan ke Login.dart
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                "Masuk Sekarang",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Input decoration reusable
  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // 🔹 TextField reusable
  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hint: hint),
      validator: (value) =>
      (value == null || value.trim().isEmpty) ? "Wajib diisi" : null,
    );
  }

  // 🔹 Dropdown reusable
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(hint: "Pilih"),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
