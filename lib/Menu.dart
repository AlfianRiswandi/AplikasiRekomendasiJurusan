import 'package:flutter/material.dart';
import 'NilaiRapor.dart';
import 'PanduanTes.dart';

class MenuPage extends StatelessWidget {
  final String idUser;  // dari login
  final String idSiswa; // dari login

  const MenuPage({super.key, required this.idUser, required this.idSiswa});

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconBg = Colors.white,
    Color iconColor = Colors.black87,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03A9F4), // warna biru cerah
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Selamat Datang !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Aplikasi ini membantu siswa dan siswi SMA di Indonesia "
                          "dalam menentukan jurusan kuliah yang sesuai berdasarkan "
                          "nilai rapor dan kepribadian.",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              // Menu Items
              buildMenuItem(
                icon: Icons.text_fields,
                title: "Input Nilai Rapor",
                subtitle: "Masukkan nilai rapor kamu untuk rekomendasi jurusan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NilaiRapor(idUser: idUser, idSiswa: idSiswa),
                    ),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.assignment,
                title: "Tes Kepribadian",
                subtitle:
                "Kerjakan tes untuk mengetahui minat dan bakatmu, lalu dapatkan rekomendasi jurusan yang sesuai",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PanduanTes(idUser: idUser, idSiswa: idSiswa),
                    ),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.info,
                title: "Tentang Kepribadian",
                subtitle:
                "Kenali tipe kepribadianmu (RIASEC) dan temukan jurusan kuliah yang paling cocok untukmu.",
                iconBg: Colors.black,
                iconColor: Colors.white,
                onTap: () {
                  // nanti diarahkan ke halaman TentangKepribadian.dart
                },
              ),
              buildMenuItem(
                icon: Icons.person,
                title: "Profil",
                subtitle:
                "Lihat dan ubah informasi profil kamu di aplikasi ini.",
                onTap: () {
                  // nanti diarahkan ke halaman Profil.dart
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
