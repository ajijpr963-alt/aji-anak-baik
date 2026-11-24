
import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final angka1Controller = TextEditingController();
  final angka2Controller = TextEditingController();

  final Color peach = const Color(0xFFB88C83);
  final Color cream = const Color(0xFFFFF8F5);
  final Color brown = const Color(0xFF57443F);

  String hasil = '0';
  String operasiTerakhir = '';

  void hitung(String operasi) {
    final angka1 = double.tryParse(angka1Controller.text);
    final angka2 = double.tryParse(angka2Controller.text);

    if (angka1 == null || angka2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kedua angka terlebih dahulu!'),
        ),
      );
      return;
    }

    if (operasi == '/' && angka2 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa membagi dengan nol!'),
        ),
      );
      return;
    }

    double nilai = 0;

    switch (operasi) {
      case '+':
        nilai = angka1 + angka2;
        break;
      case '-':
        nilai = angka1 - angka2;
        break;
      case '*':
        nilai = angka1 * angka2;
        break;
      case '/':
        nilai = angka1 / angka2;
        break;
    }

    setState(() {
      hasil = nilai == nilai.roundToDouble()
          ? nilai.toInt().toString()
          : nilai.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

      operasiTerakhir = operasi;
    });
  }

  void reset() {
    setState(() {
      angka1Controller.clear();
      angka2Controller.clear();
      hasil = '0';
      operasiTerakhir = '';
    });
  }

  Widget inputAngka(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan angka',
            prefixIcon: Icon(Icons.tag, color: peach),
            filled: true,
            fillColor: cream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget tombolOperasi(
    String label,
    String simbol,
    IconData icon,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: () => hitung(simbol),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3E5DF),
            foregroundColor: brown,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: peach, size: 23),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    angka1Controller.dispose();
    angka2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: brown,
        elevation: 0,
        title: const Text(
          'My Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let’s calculate!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: brown,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Masukkan angka yang ingin dihitung.',
                style: TextStyle(color: brown.withOpacity(0.65)),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: peach.withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    inputAngka('Angka pertama', angka1Controller),
                    const SizedBox(height: 22),
                    inputAngka('Angka kedua', angka2Controller),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Pilih Operasi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: brown,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  tombolOperasi('Tambah', '+', Icons.add),
                  tombolOperasi('Kurang', '-', Icons.remove),
                ],
              ),

              Row(
                children: [
                  tombolOperasi('Kali', '*', Icons.close),
                  tombolOperasi('Bagi', '/', Icons.horizontal_rule),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  color: peach,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HASIL PERHITUNGAN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      hasil,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    if (operasiTerakhir.isNotEmpty)
                      Text(
                        'Operasi: $operasiTerakhir',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: peach,
                    padding: const EdgeInsets.all(15),
                    side: BorderSide(color: peach),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke Main Menu'),
                  style: TextButton.styleFrom(
                    foregroundColor: brown,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'Made with care ♡',
                  style: TextStyle(
                    color: brown.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
