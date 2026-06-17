import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'menu.dart';
import 'NilaiRapor.dart';
import 'PanduanTes.dart';
import 'TesKepribadian.dart';

class HasilTesKepribadian extends StatefulWidget {
  final String idSiswa;
  final String idUser;

  const HasilTesKepribadian({
    super.key,
    required this.idSiswa,
    required this.idUser,
  });

  @override
  State<HasilTesKepribadian> createState() => _HasilTesKepribadianState();
}

class _HasilTesKepribadianState extends State<HasilTesKepribadian> {
  int _selectedIndex = 2;

  Future<Map<String, dynamic>> fetchHasilTes() async {
    final url =
    Uri.parse("https://rekomendasiprogramstudi.com/api/hasilteskepribadian.php?id_user=${widget.idUser}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        return data["hasil_tes"];
      } else {
        throw Exception(data["message"] ?? "Gagal ambil data");
      }
    } else {
      throw Exception("Gagal koneksi ke server");
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MenuPage(idUser: widget.idUser, idSiswa: widget.idSiswa),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NilaiRapor(idUser: widget.idUser, idSiswa: widget.idSiswa),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TesKepribadian(idUser: widget.idUser, idSiswa: widget.idSiswa),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PanduanTes(idUser: widget.idUser, idSiswa: widget.idSiswa),
        ),
      );
    }
  }

  String getImagePath(String tipe) {
    return "assets/image/MBTI_${tipe.toUpperCase()}.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchHasilTes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text("Data tidak ditemukan"));
            }

            final hasil = snapshot.data!;
            final tipe = hasil["tipe_kepribadian"] ?? "UNKNOWN";
            final kompetensi = hasil["kompetensi"] ?? "-";
            final deskripsi = hasil["deskripsi"] ?? "-";

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Hasil Tes Kepribadian",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gambar sesuai MBTI
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      getImagePath(tipe),
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 100, color: Colors.red);
                      },
                    ),
                  ),

                  // Tipe Kepribadian
                  Text(
                    "Tipe Kepribadian Anda: $tipe",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card informasi kepribadian
                  Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kompetensi:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            kompetensi,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Deskripsi Kepribadian:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            deskripsi,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF03A9F4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_fields), label: "Nilai Rapor"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: "Tes Kepribadian"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
