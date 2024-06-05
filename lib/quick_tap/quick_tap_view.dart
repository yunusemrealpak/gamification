import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class QuickTapView extends StatefulWidget {
  const QuickTapView({super.key});

  @override
  _QuickTapViewState createState() => _QuickTapViewState();
}

class _QuickTapViewState extends State<QuickTapView>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  bool _gameStarted = false;
  final int _maxTaps = 100;
  final int _timeLimit = 10; // seconds
  Timer? _timer;
  int _remainingTime = 10;
  List<TapImage> _tapImages = [];

  bool _tryAgain = false;

  void _startGame() {
    setState(() {
      _tapCount = 0;
      _gameStarted = true;
      _remainingTime = _timeLimit;
      _tapImages = [];
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _endGame();
      }
    });
  }

  void _resetGame() {
    _timer?.cancel();
    _disposeTapImages();
    setState(() {
      _tapCount = 0;
      _gameStarted = false;
      _remainingTime = _timeLimit;
      _tapImages = [];
    });
  }

  void _endGame() {
    _timer?.cancel();
    _disposeTapImages();
    setState(() {
      _gameStarted = false;
      _tryAgain = true;
    });
    _showResultDialog();
  }

  void tryAgain() {
    _resetGame();
    _startGame();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sonuç'),
        content: Text(_tapCount >= _maxTaps
            ? 'Tebrikler! Ödül kazandınız.'
            : 'Maalesef, ödül kazanamadınız.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _registerTap(TapDownDetails details) {
    if (_gameStarted) {
      setState(() {
        _tapCount++;
        final screenWidth = MediaQuery.of(context).size.width;
        final isLeftSide = details.localPosition.dx < screenWidth / 2;
        _tapImages.add(
          TapImage(
            position: details.localPosition,
            controller: AnimationController(
              duration: const Duration(
                  milliseconds: 1500), // Animation duration set to 1.5 seconds
              vsync: this,
            )..forward(),
            isLeftSide: isLeftSide,
            onDispose: _removeDisposedTapImage,
          ),
        );
        if (_tapCount >= _maxTaps) {
          _endGame();
        }
      });
    }
  }

  void _removeDisposedTapImage(TapImage tapImage) {
    setState(() {
      _tapImages.remove(tapImage);
    });
  }

  void _disposeTapImages() {
    for (var tapImage in _tapImages) {
      tapImage.controller.dispose();
    }
    _tapImages.clear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeTapImages();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Tıklama Oyunu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: _registerTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(child: _buildButton()),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                _formatTime(_remainingTime),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                '$_tapCount / $_maxTaps',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            ..._tapImages.map((tapImage) => tapImage.build(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    if (!_gameStarted && !_tryAgain) {
      return ElevatedButton(
        onPressed: _startGame,
        child: const Text('Oyunu Başlat'),
      );
    }

    if (_tryAgain && _remainingTime <= 0) {
      return ElevatedButton(
        onPressed: tryAgain,
        child: const Text('Tekrar Dene'),
      );
    }

    return const SizedBox.shrink();
  }
}

class TapImage {
  final Offset position;
  final AnimationController controller;
  final bool isLeftSide;
  final Function(TapImage) onDispose;

  TapImage(
      {required this.position,
      required this.controller,
      required this.isLeftSide,
      required this.onDispose}) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onDispose(this);
      }
    });
  }

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final direction = isLeftSide ? 1 : -1;
        final horizontalOffset = 50 * controller.value * direction;
        final verticalOffset =
            -100 * (controller.value - controller.value * controller.value);
        return Positioned(
          left: position.dx - 15 + horizontalOffset,
          top: position.dy - 15 + verticalOffset,
          child: Transform.rotate(
            angle: controller.value * 2 * pi,
            child: Opacity(
              opacity: 1.0 - controller.value,
              child: Image.asset(
                'assets/png/gift.png', // Updated image path
                width: 60,
                height: 60,
              ),
            ),
          ),
        );
      },
    );
  }
}
