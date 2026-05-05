import 'package:aula3_navegacao/rotas.dart';
import 'package:aula3_navegacao/tela_principal.dart';
import 'package:aula3_navegacao/tela_secundaria.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula 03',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Exemplo form e navegação'),
      routes: {
        Rotas.telaSecundaria : (context) => TelaDados() 
      },
    );
  }
}


