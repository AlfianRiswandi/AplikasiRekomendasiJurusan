import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import halaman lain
import 'menu.dart';
import 'DetailNilaiRapor.dart';
import 'PanduanTes.dart'; // <-- tambahkan ini

class NilaiRapor extends StatefulWidget {
  final String idUser;
  final String idSiswa;

  const NilaiRapor({super.key, required this.idUser, required this.idSiswa});

  @override
  State<NilaiRapor> createState() => _NilaiRaporState();
}

class _NilaiRaporState extends State<NilaiRapor> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  final List<String> _mapel = [
    "Matematika",
    "Bahasa Indonesia",
    "Bahasa Inggris",
    "Fisika",
    "Kimia",
    "Biologi",
    "Teknologi Informasi"
  ];

  int _selectedIndex = 1; // posisi default di NilaiRapor

  @override
  void initState() {
    super.initState();
    for (var m in _mapel) {
      _controllers[m] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _simpanNilai() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "id_siswa": widget.idSiswa,
      "MTK": int.tryParse(_controllers["Matematika"]!.text) ?? 0,
      "BIND": int.tryParse(_controllers["Bahasa Indonesia"]!.text) ?? 0,
      "BING": int.tryParse(_controllers["Bahasa Inggris"]!.text) ?? 0,
      "FIS": int.tryParse(_controllers["Fisika"]!.text) ?? 0,
      "KIM": int.tryParse(_controllers["Kimia"]!.text) ?? 0,
      "BIO": int.tryParse(_controllers["Biologi"]!.text) ?? 0,
      "TI": int.tryParse(_controllers["Teknologi Informasi"]!.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse("https://rekomendasiprogramstudi.com/api/nilairapor.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Data berhasil dikirim")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error server: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal terhubung ke server: $e")),
      );
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Masukkan Nilai $label",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Nilai $label harus diisi";
          final n = int.tryParse(value);
          if (n == null) return "Nilai $label harus angka";
          if (n < 0 || n > 100) return "Nilai harus 0–100";
          return null;
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // biar ga reload halaman sama
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MenuPage(idUser: widget.idUser, idSiswa: widget.idSiswa),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>PanduanTes(idUser: widget.idUser, idSiswa: widget.idSiswa), // arahkan ke PanduanTes
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03A9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF03A9F4),
        title: const Text(
          "Input Nilai Rapor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._mapel.map((m) => buildTextField(m, _controllers[m]!)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _simpanNilai,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A9F4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan Nilai",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNilaiRapor(
                            idUser: widget.idUser,
                            idSiswa: widget.idSiswa,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Lihat Detail Nilai",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF03A9F4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: "Nilai Rapor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Tes Kepribadian",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
