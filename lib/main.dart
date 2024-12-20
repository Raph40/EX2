import 'package:exercicioavaliacao2/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(exercicioAvaliacao2());
}

class exercicioAvaliacao2 extends StatelessWidget {
  const exercicioAvaliacao2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (context) => const loginScreen(),
      },
    );
  }
}
