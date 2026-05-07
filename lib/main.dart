import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/tarefa_provider.dart';
import 'rotas.dart';
import 'screens/tela_boas_vindas.dart';
import 'screens/tela_lista.dart';
import 'screens/tela_formulario.dart';
import 'screens/tela_detalhe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TarefaProvider(),
      child: MaterialApp(
        title: 'App de Tarefas',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        initialRoute: Rotas.boasVindas,
        routes: {
          Rotas.boasVindas: (context) => const TelaBoasVindas(),
          Rotas.lista: (context) => const TelaLista(),
          Rotas.formulario: (context) => const TelaFormulario(),
          Rotas.detalhe: (context) => const TelaDetalhe(),
        },
      ),
    );
  }
}
