import 'package:flutter/material.dart';

// Import halaman lain
import 'menu.dart';
import 'NilaiRapor.dart';
import 'TesKepribadian.dart';
import 'HasilTesKepribadian.dart';

class PanduanTes extends StatefulWidget {
  final String idUser;
  final String idSiswa;

  const PanduanTes({
    super.key,
    required this.idUser,
    required this.idSiswa,
  });

  @override
  State<PanduanTes> createState() => _PanduanTesState();
}

class _PanduanTesState extends State<PanduanTes> {
  int _selectedIndex = 2; // posisi default di Tes Kepribadian

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Navigasi antar halaman
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MenuPage(idUser: widget.idUser, idSiswa: widget.idSiswa),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NilaiRapor(idUser: widget.idUser, idSiswa: widget.idSiswa),
          ),
        );
        break;
      case 2:
      // tetap di halaman ini
        break;
      case 3:
      // TODO: arahkan ke Profil (belum dibuat)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // warna background biru
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Selamat Datang di\nTes Temui Program Studi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Tes ini dirancang untuk membantumu memahami minat berdasarkan MBTI. "
                        "Dengan menjawab beberapa pertanyaan, kamu akan mendapatkan rekomendasi jurusan "
                        "atau bidang yang sesuai dengan potensimu.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "📌 Petunjuk Tes:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("● Bacalah setiap pertanyaan dengan teliti."),
                  const Text("● Pilih skor 1–10 dengan mengklik angka:"),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("○ 1 = tidak sesuai"),
                        Text("○ 10 = sangat sesuai"),
                      ],
                    ),
                  ),
                  const Text("● Jawab dengan jujur agar hasil lebih akurat."),
                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "Klik tombol di bawah ini.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Mulai Tes
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TesKepribadian(
                              idUser: widget.idUser,
                              idSiswa: widget.idSiswa,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Mulai Tes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Kembali
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPage(
                              idUser: widget.idUser,
                              idSiswa: widget.idSiswa,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Kembali",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Lihat Hasil Tes (Baru)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HasilTesKepribadian(
                              idUser: widget.idUser,
                              idSiswa: widget.idSiswa,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Lihat Hasil Tes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // BottomNavigationBar
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
