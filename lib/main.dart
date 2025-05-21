import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

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

const List<String> phaseTitles = [
  'Saudações',
  'Dias da Semana',
  'Meses do ano',
  'Frutas',
  'Números',
  'Animais',
  'Cores',
  'Família',
  'Objetos',
  'Comidas',
];

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
    final List<Offset> positions = List.generate(
      10,
      (index) => Offset(
        MediaQuery.of(context).size.width * (index % 2 == 0 ? 0.2 : 0.6),
        40 + 110.0 * index,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 100),
            GestureDetector(
              onTap:
                  widget.lives == 0
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MemoryGameScreen(
                                  onCompleted: () {
                                    widget.onRecoverLives(3);
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                ),
                          ),
                        );
                      }
                      : null,
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  Text(
                    " ${widget.lives}",
                    style: TextStyle(color: Colors.white),
                  ),
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
            children: List.generate(10, (index) {
              return Positioned(
                left: positions[index].dx,
                top: positions[index].dy,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.completedPhases[index]
                            ? Colors.green
                            : Colors.grey[850],
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(40),
                  ),
                  onPressed:
                      widget.lives > 0 &&
                              (index == 0 || widget.completedPhases[index - 1])
                          ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LessonScreen(
                                      phase: index + 1,
                                      title: phaseTitles[index],
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
                            setState(() {});
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
            }),
          ),
        ),
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  final int phase;
  final String title;
  final VoidCallback onCompleted;
  final VoidCallback onLifeLost;
  final int Function() getLives;

  LessonScreen({
    required this.phase,
    required this.title,
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
  late List<QuestionItem> phaseQuestions;

  @override
  void initState() {
    super.initState();
    phaseQuestions = getQuestionsForPhase(widget.phase);
  }

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

    if (currentQuestion < phaseQuestions.length - 1) {
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
        title: Text(widget.title),
        backgroundColor: Colors.purple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  "$currentLives",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              phaseQuestions[currentQuestion].question,
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Image.asset(
              phaseQuestions[currentQuestion].imageAsset,
              height: 200,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed:
                          () => answer(
                            phaseQuestions[currentQuestion]
                                    .correctAnswerIndex ==
                                0,
                          ),
                      child: Text(phaseQuestions[currentQuestion].answer1),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed:
                          () => answer(
                            phaseQuestions[currentQuestion]
                                    .correctAnswerIndex ==
                                1,
                          ),
                      child: Text(phaseQuestions[currentQuestion].answer2),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionItem {
  final String question;
  final String imageAsset;
  final String answer1;
  final String answer2;
  final int correctAnswerIndex;

  QuestionItem({
    required this.question,
    required this.imageAsset,
    required this.answer1,
    required this.answer2,
    required this.correctAnswerIndex,
  });
}

List<QuestionItem> getQuestionsForPhase(int phase) {
  switch (phase) {
    case 1:
      return [
        QuestionItem(
          question: "______! Como você está hoje?",
          imageAsset: 'assets/fase 0/oi.png',
          answer1: "oi",
          answer2: "tchau",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______! Durma bem!",
          imageAsset: 'assets/fase 0/boa noite.png',
          answer1: "Boa noite",
          answer2: "oi",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______! posso ajudar em algo?",
          imageAsset: 'assets/fase 0/boa tarde.png',
          answer1: "Obrigado",
          answer2: "Boa tarde",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "______! Dormiu bem?",
          imageAsset: 'assets/fase 0/bom dia.png',
          answer1: "Tchau",
          answer2: "Bom dia",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "______! pelo presente adorei!",
          imageAsset: 'assets/fase 0/obrigado.png',
          answer1: "Obrigado",
          answer2: "oi",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______! Você me alcança o lápis",
          imageAsset: 'assets/fase 0/por favor.png',
          answer1: "Boa noite",
          answer2: "Por favor",
          correctAnswerIndex: 1,
        ),
      ];
    case 2:
      return [
        QuestionItem(
          question: "Segunda-feira, terça-feira, quarta-feira são dias ______",
          imageAsset: 'assets/fase1/semana.png',
          answer1: "da semana",
          answer2: "do mercado",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______ é o primeiro dia da semana",
          imageAsset: 'assets/fase1/domingo.png',
          answer1: "Segunda-feira",
          answer2: "Domingo",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "______ tem gosto de já foi metade, mas ainda falta metade",
          imageAsset: 'assets/fase1/quarta.png',
          answer1: "Quarta-feira",
          answer2: "Domingo",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question:
              "______ eu sempre prometo começar a dieta... e esqueço na hora do almoço",
          imageAsset: 'assets/fase1/segunda.png',
          answer1: "Sexta-feira",
          answer2: "Segunda-feira",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question:
              "______ é quando muitas pessoas comemoram o fim do trabalho.",
          imageAsset: 'assets/fase1/sexta.png',
          answer1: "Sexta-feira",
          answer2: "terça-feira",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______ vem depois da segunda.",
          imageAsset: 'assets/fase1/terça.png',
          answer1: "quinta-feira",
          answer2: "terça-feira",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "______ é o dia antes de sexta-feira.",
          imageAsset: 'assets/fase1/quinta.png',
          answer1: "quinta-feira",
          answer2: "quarta-feira",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "______ é o dia preferido de quem espera o fim de semana.",
          imageAsset: 'assets/fase1/sabado.png',
          answer1: "quinta-feira",
          answer2: "sábado",
          correctAnswerIndex: 1,
        ),
      ];
    case 3:
      return [
        QuestionItem(
          question: "_____ é o mês do Réveillon",
          imageAsset: 'assets/fase2/janeiro.png',
          answer1: "Janeiro",
          answer2: "novembro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "Janeiro, fevereiro, março são _____",
          imageAsset: 'assets/fase2/meses do ano.png',
          answer1: "meses do ano",
          answer2: "semnas do ano",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ é o mês mais curto",
          imageAsset: 'assets/fase2/fevereiro.png',
          answer1: "outubro",
          answer2: "fevereiro",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "_____ comemora-se o dia internacional da mulher",
          imageAsset: 'assets/fase2/março.png',
          answer1: "março",
          answer2: "setembro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ é o mês do natal",
          imageAsset: 'assets/fase2/dezembro.png',
          answer1: "dezembro",
          answer2: "outubro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question:
              "_____ muitas lojas fazem desconto por causa dio dia do consumidor",
          imageAsset: 'assets/fase2/outubro.png',
          answer1: "outubro",
          answer2: "setembro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ mês da proclamação da república",
          imageAsset: 'assets/fase2/novembro.png',
          answer1: "março",
          answer2: "novembro",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "_____ o mês da Páscoa, e tem o dia da mentira",
          imageAsset: 'assets/fase2/abril.png',
          answer1: "novembro",
          answer2: "abril",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "_____ marca o início da primavera no Brasil",
          imageAsset: 'assets/fase2/outubro.png',
          answer1: "outubro",
          answer2: "abril",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ mês do dia dos pais",
          imageAsset: 'assets/fase2/agosto.png',
          answer1: "agosto",
          answer2: "outubro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ mês do dia do trabalho",
          imageAsset: 'assets/fase2/maio.png',
          answer1: "maio",
          answer2: "outubro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ mês do dia do amigo",
          imageAsset: 'assets/fase2/julho.png',
          answer1: "julho",
          answer2: "outubro",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "_____ conhecido pelas festas juninas",
          imageAsset: 'assets/fase2/junho.png',
          answer1: "agosto",
          answer2: "junho",
          correctAnswerIndex: 1,
        ),
      ];
    case 3:
      return [
        QuestionItem(
          question: "Qual é o oposto de quente?",
          imageAsset: 'assets/fase3/frio.png',
          answer1: "Frio",
          answer2: "Morno",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "O que usamos para ver melhor?",
          imageAsset: 'assets/fase3/oculos.png',
          answer1: "Chapéu",
          answer2: "Óculos",
          correctAnswerIndex: 1,
        ),
      ];
    case 4:
      return [
        QuestionItem(
          question: "Quantas pernas tem um cachorro?",
          imageAsset: 'assets/fase4/cachorro.png',
          answer1: "Quatro",
          answer2: "Duas",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "Qual animal mia?",
          imageAsset: 'assets/fase4/gato.png',
          answer1: "Cachorro",
          answer2: "Gato",
          correctAnswerIndex: 1,
        ),
      ];
    case 5:
      return [
        QuestionItem(
          question: "Qual é o nome do planeta em que vivemos?",
          imageAsset: 'assets/fase5/terra.png',
          answer1: "Terra",
          answer2: "Marte",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "Qual é a cor do céu em um dia claro?",
          imageAsset: 'assets/fase5/ceu.png',
          answer1: "Azul",
          answer2: "Vermelho",
          correctAnswerIndex: 0,
        ),
      ];
    case 6:
      return [
        QuestionItem(
          question: "O que usamos para cortar papel?",
          imageAsset: 'assets/fase6/tesoura.png',
          answer1: "Tesoura",
          answer2: "Cola",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "Qual fruta é amarela por fora e branca por dentro?",
          imageAsset: 'assets/fase6/banana.png',
          answer1: "Banana",
          answer2: "Maçã",
          correctAnswerIndex: 0,
        ),
      ];
    case 7:
      return [
        QuestionItem(
          question: "O que usamos para beber água?",
          imageAsset: 'assets/fase7/copo.png',
          answer1: "Prato",
          answer2: "Copo",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "Qual objeto usamos para andar em dias de chuva?",
          imageAsset: 'assets/fase7/guarda_chuva.png',
          answer1: "Guarda-chuva",
          answer2: "Boné",
          correctAnswerIndex: 0,
        ),
      ];
    case 8:
      return [
        QuestionItem(
          question: "Qual animal tem uma longa tromba?",
          imageAsset: 'assets/fase8/elefante.png',
          answer1: "Leão",
          answer2: "Elefante",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "Qual animal pula e vive na água e na terra?",
          imageAsset: 'assets/fase8/sapo.png',
          answer1: "Sapo",
          answer2: "Cobra",
          correctAnswerIndex: 0,
        ),
      ];
    case 9:
      return [
        QuestionItem(
          question: "O que usamos para escovar os dentes?",
          imageAsset: 'assets/fase9/escova.png',
          answer1: "Pente",
          answer2: "Escova de dentes",
          correctAnswerIndex: 1,
        ),
        QuestionItem(
          question: "Qual parte do corpo usamos para ouvir?",
          imageAsset: 'assets/fase9/ouvido.png',
          answer1: "Olhos",
          answer2: "Ouvidos",
          correctAnswerIndex: 1,
        ),
      ];
    case 10:
      return [
        QuestionItem(
          question: "Qual o nome do satélite natural da Terra?",
          imageAsset: 'assets/fase10/lua.png',
          answer1: "Lua",
          answer2: "Sol",
          correctAnswerIndex: 0,
        ),
        QuestionItem(
          question: "Qual é o maior órgão do corpo humano?",
          imageAsset: 'assets/fase10/pele.png',
          answer1: "Fígado",
          answer2: "Pele",
          correctAnswerIndex: 1,
        ),
      ];
    default:
      return [
        QuestionItem(
          question: "",
          imageAsset: 'assets/padrao.png',
          answer1: "Sim",
          answer2: "Não",
          correctAnswerIndex: 0,
        ),
      ];
  }
}

class MemoryGameScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  MemoryGameScreen({required this.onCompleted});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<_CardItem> items = [];
  List<bool> revealed = [];
  int? selectedIndex;
  int matches = 0;

  @override
  void initState() {
    super.initState();
    List<String> letters = ['A', 'E', 'I', 'O', 'U'];
    items =
        letters
            .expand(
              (letter) => [
                _CardItem(letter: letter, isImage: true),
                _CardItem(letter: letter, isImage: false),
              ],
            )
            .toList();
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
      if (items[selectedIndex!].letter == items[index].letter &&
          items[selectedIndex!].isImage != items[index].isImage) {
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
                final item = items[index];
                return GestureDetector(
                  onTap: () => reveal(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child:
                          revealed[index]
                              ? item.isImage
                                  ? Image.asset(
                                    'assets/minigame/${item.letter.toLowerCase()}.png',
                                    fit: BoxFit.contain,
                                  )
                                  : Text(
                                    item.letter,
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                              : Icon(
                                Icons.help_outline,
                                size: 40,
                                color: Colors.white,
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

class _CardItem {
  final String letter;
  final bool isImage;

  _CardItem({required this.letter, required this.isImage});
}
