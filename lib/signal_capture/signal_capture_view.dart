import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SignalCaptureView extends StatefulWidget {
  const SignalCaptureView({super.key});

  @override
  _SignalCaptureViewState createState() => _SignalCaptureViewState();
}

class _SignalCaptureViewState extends State<SignalCaptureView> {
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  Timer? _timer;
  bool _isGameStarted = false;
  int _score = 0;
  double _signalDirection = 0.0;

  @override
  void initState() {
    super.initState();
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_isGameStarted) {
        _checkSignalCapture();
      }
    });

    _generateNewSignalDirection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateNewSignalDirection() {
    setState(() {
      _signalDirection =
          Random().nextDouble() * 2 * pi; // 0 ile 360 derece arasında bir açı
    });
  }

  void _checkSignalCapture() {
    double direction = atan2(_y, _x); // Telefonun yönünü hesapla
    if ((direction - _signalDirection).abs() < 0.2) {
      // Yakalama hassasiyeti (radyan cinsinden)
      setState(() {
        _score += 1;
        _generateNewSignalDirection();
      });
    }
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _score = 0;
      _generateNewSignalDirection();
    });
  }

  @override
  Widget build(BuildContext context) {
    double direction = atan2(_y, _x);
    double angle = _signalDirection - direction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinyal Yakalama Oyunu'),
      ),
      body: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: angle,
              child: const Icon(
                Icons.wifi,
                size: 100,
                color: Colors.green,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Puan: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
