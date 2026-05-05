import 'package:aula3_navegacao/pessoa.dart';
import 'package:aula3_navegacao/rotas.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _dadosSalvos = false;
  var _estaFeliz = false;
  Pessoa? _pessoa;
  final _nomeController = TextEditingController();

  void _mostraDados() {
    setState(() {
      _pessoa = Pessoa(
          estaFeliz:  _estaFeliz,
          nome:  _nomeController.text
        );
      _dadosSalvos = _pessoa?.nome != "";
    });
  }

  void _trocaTela() {
    if (_dadosSalvos) {
      Navigator.pushNamed(
        context,
        Rotas.telaSecundaria,
        arguments : _pessoa,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(_dadosSalvos ? "Dados gravados" : "Nenhum dado salvo!"),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "Informe o nome",
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              title: Text("você esta feliz?"),
              value: _estaFeliz,
              onChanged: (bool? value) => setState(() => _estaFeliz = value==true),
            ),
            ElevatedButton(
              onPressed: _mostraDados,
              child: const Icon(Icons.done_outline_outlined),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _trocaTela,
        tooltip: 'enviar',
        child: const Icon(Icons.navigate_next_rounded),
      ),
    );
  }
}
