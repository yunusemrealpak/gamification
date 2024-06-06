import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SatelliteView extends StatefulWidget {
  const SatelliteView({super.key});

  @override
  State<SatelliteView> createState() => _SatelliteViewState();
}

class _SatelliteViewState extends State<SatelliteView> {
  double _xPosition = 0;
  double _yPosition = 0;
  double _xVelocity = 0;
  double _yVelocity = 0;
  static const double _friction = 0.9;
  static const double _accelerationFactor = 0.02;
  Timer? _timer;

  double _orbitAngle = 90;
  static const double _orbitRadius = 150;
  static const double _angleIncrement = 0.01;

  bool _isPopupDisplayed = false;

  @override
  void initState() {
    super.initState();
    Sensors().accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _xVelocity += event.x * _accelerationFactor;
        _yVelocity += event.y * _accelerationFactor;
      });
    });

    Future.microtask(() {
      final size = MediaQuery.of(context).size;

      // Uydunun başlangıç konumunu rastgele yap
      Random random = Random();
      _xPosition = random.nextDouble() * 100 - 100; // -100 ile 100 arasında rastgele bir değer
      _yPosition = size.height / 4 + random.nextDouble() * 100; // -100 ile 100 arasında rastgele bir değer

      _timer = Timer.periodic(const Duration(milliseconds: 16), (e) {
        setState(() {
          _xPosition += _xVelocity;
          _yPosition += _yVelocity;
          _xVelocity *= _friction;
          _yVelocity *= _friction;

          _orbitAngle += _angleIncrement;
          if (_orbitAngle >= 2 * pi) {
            _orbitAngle -= 2 * pi;
          }
        });

        if (_isSatelliteInPlace(centerX + _orbitRadius * cos(_orbitAngle) - centerX, centerY + _orbitRadius * sin(_orbitAngle) - centerY) && !_isPopupDisplayed) {
          _isPopupDisplayed = true;
          _showRewardDialog();
        }
      });
    });
  }

  double get centerX => MediaQuery.of(context).size.width / 2 - 15;
  double get centerY => MediaQuery.of(context).size.height * 0.57;

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ödül Kazandınız!'),
          content: const Text('Uyduyu yörüngeye başarıyla oturttunuz.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop(); // Pop the dialog
                Navigator.of(context).pop(); // Pop the game screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isSatelliteInPlace(double targetX, double targetY) {
    return (_xPosition - targetX).abs() < 10 && (_yPosition - targetY).abs() < 10;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double targetX = centerX + _orbitRadius * cos(_orbitAngle);
    double targetY = centerY + _orbitRadius * sin(_orbitAngle);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Satellite Game',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Image.asset('assets/png/space.jpeg', width: size.width, height: size.height, fit: BoxFit.cover),
          Positioned(
            bottom: size.height * 0.075,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/lottie/earth.json',
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            left: targetX - 20,
            top: targetY - 20 + size.height * 0.25,
            child: Lottie.asset(
              'assets/lottie/satellite_point.json',
              width: 75,
              height: 75,
            ),
          ),
          Positioned(
            left: centerX + _xPosition - 15,
            top: centerY - _yPosition - 15,
            child: Lottie.asset(
              'assets/lottie/satellite.json',
              width: 75,
              height: 75,
            ),
          ),
        ],
      ),
    );
  }
}
