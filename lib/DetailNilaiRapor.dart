import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'menu.dart';
import 'NilaiRapor.dart';
import 'PanduanTes.dart';

class DetailNilaiRapor extends StatefulWidget {
  final String idUser;
  final String idSiswa;

  const DetailNilaiRapor({super.key, required this.idUser, required this.idSiswa});

  @override
  State<DetailNilaiRapor> createState() => _DetailNilaiRaporState();
}

class _DetailNilaiRaporState extends State<DetailNilaiRapor> {
  int _selectedIndex = 1;

  // Endpoint API kamu
  final String apiUrl = "https://rekomendasiprogramstudi.com/api/detailnilairapor.php";

  List<Map<String, dynamic>> nilaiMapel = [];

  @override
  void initState() {
    super.initState();
    _fetchNilai();
  }

  Future<void> _fetchNilai() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl?id_siswa=${widget.idSiswa}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          final rapor = data["data"];

          setState(() {
            nilaiMapel = [
              {"key": "MTK", "mapel": "Matematika", "nilai": double.parse(rapor["MTK"].toString()), "icon": Icons.square_foot},
              {"key": "BING", "mapel": "Bahasa Inggris", "nilai": double.parse(rapor["BING"].toString()), "icon": Icons.language},
              {"key": "FIS", "mapel": "Fisika", "nilai": double.parse(rapor["FIS"].toString()), "icon": Icons.science},
              {"key": "KIM", "mapel": "Kimia", "nilai": double.parse(rapor["KIM"].toString()), "icon": Icons.biotech},
              {"key": "BIO", "mapel": "Biologi", "nilai": double.parse(rapor["BIO"].toString()), "icon": Icons.eco},
              {"key": "TI", "mapel": "Teknologi Informasi", "nilai": double.parse(rapor["TI"].toString()), "icon": Icons.memory},
            ];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetch nilai: $e");
    }
  }

  Future<void> _editNilai(Map<String, dynamic> item) async {
    TextEditingController nilaiController =
    TextEditingController(text: item["nilai"].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Nilai - ${item['mapel']}"),
          content: TextField(
            controller: nilaiController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Nilai",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                final newNilai = double.tryParse(nilaiController.text);
                if (newNilai == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nilai tidak valid")),
                  );
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse(apiUrl),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "id_siswa": widget.idSiswa,
                      item["key"]: newNilai.toInt(), // update kolom spesifik
                    }),
                  );

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data["status"] == "success") {
                      setState(() {
                        item["nilai"] = newNilai;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Nilai ${item['mapel']} berhasil diperbarui")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal update: ${data['message']}")),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(
            idUser: widget.idUser,
            idSiswa: widget.idSiswa,
          ),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NilaiRapor(
            idUser: widget.idUser,
            idSiswa: widget.idSiswa,
          ),
        ),
      );
    }else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PanduanTes(idUser: widget.idUser,
                  idSiswa: widget.idSiswa), // arahkan ke PanduanTes
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: const Text("Detail Nilai Rapor"),
      ),
      body: SafeArea(
        child: nilaiMapel.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Nilai Mata Pelajaran",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // List Nilai
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: nilaiMapel.length,
                itemBuilder: (context, index) {
                  final item = nilaiMapel[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightBlueAccent,
                        child: Icon(item["icon"], color: Colors.white),
                      ),
                      title: Text(
                        item["mapel"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("Nilai : ${item["nilai"].toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                        onPressed: () => _editNilai(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
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
