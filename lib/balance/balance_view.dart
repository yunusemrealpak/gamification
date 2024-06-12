import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BalanceView extends StatefulWidget {
  const BalanceView({super.key});

  @override
  _BalanceViewState createState() => _BalanceViewState();
}

class _BalanceViewState extends State<BalanceView> {
  double _x = 0.0;
  double _y = 0.0;
  double _ballX = 0.0;
  double _ballY = 0.0;
  Timer? _timer;
  bool _isGameStarted = false;
  int _score = 0;
  static const double _ballRadius = 25.0;
  static const double _targetRadius = 50.0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_isGameStarted) {
        _checkBalance();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkBalance() {
    if (_isBallInTarget()) {
      setState(() {
        _score += 1;
      });
    }
  }

  bool _isBallInTarget() {
    return sqrt(pow(_ballX - 0, 2) + pow(_ballY - 0, 2)) <
        (_targetRadius - _ballRadius);
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _score = 0;
      _ballX = 0.0;
      _ballY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _ballX -= _x * 0.02;
    _ballY += _y * 0.02;

    if (_ballX.abs() > MediaQuery.of(context).size.width / 2 - _ballRadius) {
      _ballX = _ballX > 0
          ? MediaQuery.of(context).size.width / 2 - _ballRadius
          : -MediaQuery.of(context).size.width / 2 + _ballRadius;
    }

    if (_ballY.abs() > MediaQuery.of(context).size.height / 2 - _ballRadius) {
      _ballY = _ballY > 0
          ? MediaQuery.of(context).size.height / 2 - _ballRadius
          : -MediaQuery.of(context).size.height / 2 + _ballRadius;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dengeleme Oyunu'),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: _targetRadius * 2,
              height: _targetRadius * 2,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'Puan: $_score',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 + _ballX - _ballRadius,
            top: MediaQuery.of(context).size.height / 2 + _ballY - _ballRadius,
            child: Container(
              width: _ballRadius * 2,
              height: _ballRadius * 2,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (!_isGameStarted)
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text('Oyunu Başlat'),
              ),
            ),
        ],
      ),
    );
  }
}
