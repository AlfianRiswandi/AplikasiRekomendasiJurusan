import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'menu.dart';
import 'NilaiRapor.dart';
import 'PanduanTes.dart';
import 'HasilTesKepribadian.dart';

class TesKepribadian extends StatefulWidget {
  final String idUser;
  final String idSiswa;

  const TesKepribadian({
    super.key,
    required this.idUser,
    required this.idSiswa,
  });

  @override
  State<TesKepribadian> createState() => _TesKepribadianState();
}

class _TesKepribadianState extends State<TesKepribadian> {
  int _selectedIndex = 2;
  int _currentQuestion = 0;
  List<dynamic> _questions = [];
  bool _loading = true;

  /// Menyimpan jawaban: id_pertanyaan -> skor
  Map<String, int> _answers = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse("https://rekomendasiprogramstudi.com/api/pertanyaantes.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = data["data"] ?? [];
          _loading = false;
        });
      } else {
        throw Exception("Gagal load soal: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Kirim semua jawaban sekaligus
  Future<void> _submitAllAnswers() async {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Lengkapi semua jawaban dulu: ${_answers.length}/${_questions.length} terisi"),
        ),
      );
      return;
    }

    final answersList = _answers.entries.map((e) {
      return {
        "id_pertanyaan": int.tryParse(e.key) ?? e.key,
        "jawaban": e.value,
      };
    }).toList();

    final payload = {
      "id_siswa": widget.idSiswa,
      "tanggal_tes": DateTime.now().toString(),
      "answers": answersList,
    };

    try {
      final response = await http.post(
        Uri.parse("https://rekomendasiprogramstudi.com/api/inputjawaban.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Jawaban tersimpan")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal submit: ${response.statusCode} — ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat submit: $e")),
      );
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Tidak ada soal")),
      );
    }

    final question = _questions[_currentQuestion];
    final String idPertanyaan = question['id_pertanyaan'].toString();
    int? selectedScore = _answers[idPertanyaan];

    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        title: const Text("Tes Kepribadian MBTI"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Card Petunjuk + Grid Soal ---
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Skor 1 = Sangat Tidak Sesuai\nSkor 10 = Sangat Sesuai",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Jumlah Soal: ${_questions.length}  — Terisi: ${_answers.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          bool isSelected = _currentQuestion == index;
                          bool isAnswered = _answers.containsKey(
                              _questions[index]['id_pertanyaan'].toString());

                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestion = index;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : (isAnswered ? Colors.green : Colors.white),
                              foregroundColor: isSelected || isAnswered
                                  ? Colors.white
                                  : Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Card Soal + Jawaban ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedScore != null ? Colors.green[100] : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_currentQuestion + 1}. ${question['pertanyaan']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),

                  // Pilihan skor
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: List.generate(10, (index) {
                      int score = index + 1;
                      bool isSelected = selectedScore == score;
                      return ChoiceChip(
                        label: Text(
                          score.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        onSelected: (_) {
                          setState(() {
                            _answers[idPertanyaan] = score;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Navigasi soal
                  Row(
                    children: [
                      if (_currentQuestion > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestion--;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Previous",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      if (_currentQuestion > 0) const SizedBox(width: 12),
                      if (_currentQuestion < _questions.length - 1)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentQuestion++;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Next",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tombol Simpan Jawaban
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedScore == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Pilih skor terlebih dahulu")),
                          );
                        } else {
                          setState(() {
                            _answers[idPertanyaan] = selectedScore;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Jawaban disimpan (lokal). Tekan Kirim Semua Jawaban di soal terakhir."),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Simpan Jawaban",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol di soal terakhir
                  if (_currentQuestion == _questions.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAllAnswers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Kirim Semua Jawaban",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
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
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Lihat Hasil Tes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
