import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

import 'stracher_item.dart';

class StracherView extends StatefulWidget {
  const StracherView({super.key});

  @override
  State<StracherView> createState() => _StracherViewState();
}

class _StracherViewState extends State<StracherView> {
  List<StracherItem> items = [
    StracherItem(1, 'İndirim'),
    StracherItem(2, 'Hediye'),
    StracherItem(3, 'Kupon'),
    StracherItem(1, 'İndirim'),
    StracherItem(2, 'Hediye'),
    StracherItem(4, 'Sınırsız Paket'),
  ];

  StracherItem? selectedItem;

  @override
  void initState() {
    super.initState();

    int random = Random().nextInt(items.length);

    Future.microtask(() {
      setState(() {
        selectedItem = items[random];
      });
    });
  }

  void showWinningDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tebrikler!'),
          content: Text('Kazandınız: ${selectedItem?.value}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Kazı Kazan'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Scratcher(
              accuracy: ScratchAccuracy.low,
              brushSize: 30,
              threshold: 75,
              color: Colors.blue,
              onChange: (value) => print("Scratch progress: $value%"),
              onThreshold: () => showWinningDialog(),
              child: SizedBox(
                height: 150,
                width: 150,
                child: Center(
                  child: Text(
                    selectedItem?.value ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
