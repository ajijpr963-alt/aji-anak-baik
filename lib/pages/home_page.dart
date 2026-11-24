
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),

      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: const Color(0xFFB88C83),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF57443F),
                ),
              ),

              const SizedBox(height: 10),

              const Text('Silakan pilih menu'),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/calculator',
                    );
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text('Kalkulator'),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/players',
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('List View'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
