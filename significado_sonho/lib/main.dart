import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se o Firebase já está inicializado para evitar duplicidade
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Significado dos Sonhos',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: InterpretadorDeSonhos(),
    );
  }
}

class InterpretadorDeSonhos extends StatefulWidget {
  @override
  _InterpretadorDeSonhosState createState() => _InterpretadorDeSonhosState();
}

class _InterpretadorDeSonhosState extends State<InterpretadorDeSonhos> {
  final TextEditingController _controller = TextEditingController();
  String? _resposta;
  bool _carregando = false;

  Future<void> mostrarRespostaComEfeito(String respostaCompleta) async {
    _resposta = '';
    for (int i = 0; i < respostaCompleta.length; i++) {
      await Future.delayed(Duration(milliseconds: 20));
      setState(() {
        _resposta = respostaCompleta.substring(0, i + 1);
      });
    }
  }

  void interpretarSonho() async {
    final sonho = _controller.text.trim();

    if (sonho.isEmpty) {
      setState(() {
        _resposta = "Por favor, digite seu sonho antes de interpretar.";
      });
      return;
    }

    setState(() {
      _carregando = true;
      _resposta = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/interpretar'), // troque por IP real se for celular
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sonho': sonho}),
      );

      if (response.statusCode == 200) {
        final respostaJson = jsonDecode(response.body);
        final resposta = respostaJson['resposta'];

        await mostrarRespostaComEfeito(resposta);

        final uid = FirebaseAuth.instance.currentUser?.uid ?? "desconhecido";

        await FirebaseFirestore.instance.collection("sonhos").add({
          "uid": uid,
          "sonho": sonho,
          "resposta": resposta,
          "data": FieldValue.serverTimestamp(),
        });
      } else {
        setState(() {
          _resposta = "Erro ao interpretar o sonho.";
        });
      }
    } catch (e) {
      setState(() {
        _resposta = "Erro de conexão com o servidor.";
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void abrirHistorico() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HistoricoSonhos(),
    ));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Me conte seu sonho"),
      actions: [
        IconButton(
          icon: Icon(Icons.history),
          tooltip: "Ver histórico",
          onPressed: abrirHistorico,
        ),
      ],
    ),
    body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  maxLength: 250,
                  decoration: InputDecoration(
                    hintText: "Digite seu sonho aqui...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _carregando ? null : interpretarSonho,
                  icon: Icon(Icons.auto_awesome),
                  label: Text("Interpretar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_carregando)
                  Center(child: CircularProgressIndicator()),
                if (_resposta != null && !_carregando)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _resposta!,
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class HistoricoSonhos extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "desconhecido";

  @override
  Widget build(BuildContext context) {
    final sonhosRef = FirebaseFirestore.instance
        .collection("sonhos")
        .where("uid", isEqualTo: uid)
        .orderBy("data", descending: true);

    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Sonhos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: sonhosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("Nenhum sonho encontrado."));

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final dataHora = (data["data"] as Timestamp?)?.toDate();
              final dataFormatada = dataHora != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(dataHora)
                  : "sem data";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(data["sonho"] ?? "sem texto"),
                  subtitle: Text(data["resposta"] ?? "sem resposta"),
                  trailing: Text(dataFormatada),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
