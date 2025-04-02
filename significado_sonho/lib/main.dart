
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart'; // 💡 Para formatar data/hora

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously();

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

    await Future.delayed(Duration(seconds: 2)); // Simula IA
    final resposta = "Esse sonho pode indicar emoções profundas ou desejos não realizados.";

    setState(() {
      _resposta = resposta;
      _carregando = false;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid ?? "desconhecido";

    await FirebaseFirestore.instance.collection("sonhos").add({
      "uid": uid,
      "sonho": sonho,
      "resposta": resposta,
      "data": FieldValue.serverTimestamp(),
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Digite seu sonho aqui...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregando ? null : interpretarSonho,
              child: Text("Interpretar"),
            ),
            const SizedBox(height: 24),
            if (_carregando) CircularProgressIndicator(),
            if (_resposta != null && !_carregando)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _resposta!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
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
