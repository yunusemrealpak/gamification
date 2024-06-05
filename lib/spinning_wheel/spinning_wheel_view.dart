import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import 'painter/triangle_painter.dart';

class SpinningWheelView extends StatefulWidget {
  const SpinningWheelView({super.key});

  @override
  State<SpinningWheelView> createState() => _SpinningWheelViewState();
}

class _SpinningWheelViewState extends State<SpinningWheelView> {
  StreamController<int> controller = StreamController<int>.broadcast();

  List<String> list = [
    'İnternet',
    'İndirim Çeki',
    'Sınırsız Paket',
    'İnternet',
    'Dakika',
    'Çekiliş Yanımda',
  ];

  int selected = 0;

  @override
  void initState() {
    super.initState();
  }

  int get random => Random().nextInt(6);

  void showResultDialog(String prize) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tebrikler!'),
          content: Text('Kazandınız: $prize'),
          actions: [
            TextButton(
              onPressed: () {
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
    var items = list
        .map((e) => FortuneItem(
              child: Text(
                e,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
        .toList();

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Çarkı Çevir'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 350,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.black.withOpacity(0.35), width: 4),
                      ),
                      child: FortuneWheel(
                        selected: controller.stream,
                        animateFirst: false,
                        styleStrategy: const UniformStyleStrategy(
                          disabledIndices: [1, 3, 5],
                        ),
                        indicators: const <FortuneIndicator>[],
                        items: items,
                        onFling: () {
                          selected = random;
                          controller.add(selected);
                        },
                        onAnimationEnd: () {
                          showResultDialog(list[selected]);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CustomPaint(
                        size: const Size(
                            20, 25), // Size of the triangle container
                        painter: TrianglePainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: TextButton(
                  onPressed: () {
                    selected = random;
                    controller.add(selected);
                  },
                  child: const Text('Spin the wheel'),
                ),
              ),
            )
          ],
        ));
  }
}
