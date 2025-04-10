import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

// App Principal
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<bool> completedPhases = List.generate(10, (index) => false);
  int lives = 5;

  void recoverLives(int amount) {
    setState(() {
      lives += amount;
      if (lives > 5) lives = 5;
    });
  }

  void loseLife() {
    setState(() {
      if (lives > 0) lives--;
    });
  }

  void completePhase(int index) {
    setState(() {
      completedPhases[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIBRAS',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.blue[100],
      ),
      home: GameScreen(
        completedPhases: completedPhases,
        lives: lives,
        onPhaseCompleted: completePhase,
        onLifeLost: loseLife,
        onRecoverLives: recoverLives,
      ),
    );
  }
}

///  Tela Principal do Jogo (agora Stateful!)
class GameScreen extends StatefulWidget {
  final List<bool> completedPhases;
  final int lives;
  final Function(int) onPhaseCompleted;
  final VoidCallback onLifeLost;
  final Function(int) onRecoverLives;

  GameScreen({
    required this.completedPhases,
    required this.lives,
    required this.onPhaseCompleted,
    required this.onLifeLost,
    required this.onRecoverLives,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Offset> positions = [
      Offset(MediaQuery.of(context).size.width * 0.2, 40),
      Offset(MediaQuery.of(context).size.width * 0.5, 160),
      Offset(MediaQuery.of(context).size.width * 0.2, 280),
      Offset(MediaQuery.of(context).size.width * 0.6, 350),
      Offset(MediaQuery.of(context).size.width * 0.2, 450),
      Offset(MediaQuery.of(context).size.width * 0.6, 550),
      Offset(MediaQuery.of(context).size.width * 0.2, 650),
      Offset(MediaQuery.of(context).size.width * 0.6, 750),
      Offset(MediaQuery.of(context).size.width * 0.2, 850),
      Offset(MediaQuery.of(context).size.width * 0.6, 950),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 100),
            GestureDetector(
              onTap: widget.lives == 0
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MemoryGameScreen(onCompleted: () {
                                widget.onRecoverLives(3);
                                Navigator.pop(context);
                                setState(() {}); // Força atualização
                              }),
                        ),
                      );
                    }
                  : null,
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  Text(" ${widget.lives}", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 1250,
          child: Stack(
            children: [
              ...List.generate(10, (index) {
                return Positioned(
                  left: positions[index].dx,
                  top: positions[index].dy,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.completedPhases[index]
                          ? Colors.green
                          : Colors.grey[850],
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(40),
                    ),
                    onPressed: widget.lives > 0 &&
                            (index == 0 || widget.completedPhases[index - 1])
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonScreen(
                                  phase: index + 1,
                                  onCompleted: () {
                                    widget.onPhaseCompleted(index);
                                    setState(() {});
                                  },
                                  onLifeLost: () {
                                    widget.onLifeLost();
                                    setState(() {});
                                  },
                                  getLives: () => widget.lives,
                                ),
                              ),
                            );
                            setState(() {}); // Atualiza ao voltar
                          }
                        : null,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

// Tela de Fase
class LessonScreen extends StatefulWidget {
  final int phase;
  final VoidCallback onCompleted;
  final VoidCallback onLifeLost;
  final int Function() getLives;

  LessonScreen({
    required this.phase,
    required this.onCompleted,
    required this.onLifeLost,
    required this.getLives,
  });

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int currentQuestion = 0;
  int correctAnswers = 0;

  final List<String> questions = [
    "Qual é o sinal de 'Amigo'?",
    "Qual é o sinal de 'Obrigado'?",
    "Qual é o sinal de 'Por favor'?",
    "Qual é o sinal de 'Família'?",
    "Qual é o sinal de 'Trabalho'?",
  ];

void answer(bool isCorrect) {
  if (isCorrect) {
    correctAnswers++;
  } else {
    widget.onLifeLost();
  }


  if (widget.getLives() <= 1) {
    Navigator.pop(context); 
    return;
  }

  if (currentQuestion < questions.length - 1) {
    setState(() {
      currentQuestion++;
    });
  } else {
    if (correctAnswers >= 3) {
      widget.onCompleted();
    }
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    final currentLives = widget.getLives();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fase ${widget.phase}'),
        backgroundColor: Colors.purple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),

                SizedBox(width: 4),
                Text("$currentLives", style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              questions[currentQuestion],
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => answer(true),
              child: Text("Resposta certa"),
            ),
            ElevatedButton(
              onPressed: () => answer(false),
              child: Text("Resposta errada"),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 Mini Jogo de Memória
class MemoryGameScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  MemoryGameScreen({required this.onCompleted});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> items = [];
  List<bool> revealed = [];
  int? selectedIndex;
  int matches = 0;

  @override
  void initState() {
    super.initState();
    List<String> base = ['🍎', '🍌', '🍇', '🍓', '🍍'];
    items = [...base, ...base];
    items.shuffle(Random());
    revealed = List.generate(items.length, (_) => false);
  }

  void reveal(int index) {
    if (revealed[index] || selectedIndex == index) return;

    setState(() {
      revealed[index] = true;
    });

    if (selectedIndex == null) {
      selectedIndex = index;
    } else {
      if (items[selectedIndex!] == items[index]) {
        matches++;
        if (matches == 5) {
          Future.delayed(Duration(milliseconds: 500), () {
            widget.onCompleted();
          });
        }
        selectedIndex = null;
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            revealed[selectedIndex!] = false;
            revealed[index] = false;
            selectedIndex = null;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mini Jogo da Memória"),
        backgroundColor: Colors.purple,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double spacing = 16;
          double totalSpacingWidth = spacing * (2 + 1);
          double totalSpacingHeight = spacing * (5 + 1);
          double itemWidth = (constraints.maxWidth - totalSpacingWidth) / 2;
          double itemHeight = (constraints.maxHeight - totalSpacingHeight) / 5;

          return Padding(
            padding: EdgeInsets.all(spacing),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: itemWidth / itemHeight,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => reveal(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        revealed[index] ? items[index] : "?",
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
