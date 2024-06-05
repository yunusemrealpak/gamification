import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

import 'stracher_item.dart';

class StracherMatchView extends StatefulWidget {
  const StracherMatchView({super.key});

  @override
  State<StracherMatchView> createState() => _StracherMatchViewState();
}

class _StracherMatchViewState extends State<StracherMatchView> {
  List<GlobalKey<ScratcherState>> scratchKeys = [
    GlobalKey<ScratcherState>(),
    GlobalKey<ScratcherState>(),
    GlobalKey<ScratcherState>(),
    GlobalKey<ScratcherState>(),
    GlobalKey<ScratcherState>(),
    GlobalKey<ScratcherState>(),
  ];

  List<StracherItem> items = [
    StracherItem(1, 'İndirim'),
    StracherItem(2, 'Hediye'),
    StracherItem(3, 'Kupon'),
    StracherItem(1, 'İndirim'),
    StracherItem(2, 'Hediye'),
    StracherItem(4, 'Sınırsız Paket'),
  ];

  List<int> revealedItems = [];
  int scratchCount = 0;
  final Random _random = Random();

  void checkForWin(int id, String text) {
    revealedItems.add(id);

    setState(() {
      scratchCount++;
    });

    if (revealedItems.where((element) => element == id).length == 2) {
      showWinningDialog(text);
    } else if (scratchCount >= 3) {
      showLosingDialog();
    }
  }

  void showWinningDialog(String prize) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tebrikler!'),
          content: Text('Kazandınız: $prize'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void showLosingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Maalesef!'),
          content: const Text('Üzgünüz, kazanamadınız. Tekrar deneyin.'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      revealedItems.clear();
      scratchCount = 0;
      items.shuffle(_random);
      for (var element in scratchKeys) {
        element.currentState?.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Kazı Kazan Eşleştirme'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Kazı ve eşleştir. Aynı ikiliyi bulunca kazanırsınız.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kazılanlar: $scratchCount / 3',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 16,
              children: items.map((e) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Scratcher(
                    key: scratchKeys[items.indexOf(e)],
                    accuracy: ScratchAccuracy.low,
                    brushSize: 30,
                    threshold: 65,
                    color: Colors.blue,
                    onChange: (value) => print("Scratch progress: $value%"),
                    onThreshold: () => checkForWin(e.key, e.value),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
