import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SatelliteLaunchView extends StatefulWidget {
  const SatelliteLaunchView({super.key});

  @override
  State<SatelliteLaunchView> createState() => _SatelliteLaunchViewState();
}

class _SatelliteLaunchViewState extends State<SatelliteLaunchView>
    with SingleTickerProviderStateMixin {
  double _yPosition = 0;
  double _yVelocity = 0;
  static const double _initialAcceleration = 0.5;
  static const double _deceleration = 0.05;
  Timer? _timer;

  double _orbitAngle = 120;
  static const double _orbitRadius = 90;
  static const double _angleIncrement = 0.01;

  bool _isGameStarted = false;
  bool _isSatelliteLaunched = false;
  bool _hasWon = false;
  bool _hasLost = false;
  int _attempts = 3;
  bool _isSatelliteVisible = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.microtask(() {
      final size = MediaQuery.of(context).size;
      _yPosition = size.height / 1.5;

      _timer = Timer.periodic(const Duration(milliseconds: 16), (e) {
        if (mounted && _isGameStarted) {
          if (_isSatelliteLaunched) {
            setState(() {
              _yPosition += _yVelocity;
              _yVelocity -= _deceleration;

              if (_yPosition <= 0) {
                _attempts--;
                _yVelocity = 0;
                _yPosition = size.height / 1.5;
                _isSatelliteLaunched = false;
                if (_attempts == 0) {
                  _hasLost = true;
                  _isGameStarted = false;
                  _controller.forward();
                }
              }

              if (_isSatelliteInPlace()) {
                if (!_hasWon) {
                  setState(() {
                    _hasWon = true;
                    _isSatelliteVisible = false;
                    _isGameStarted = false;
                  });
                  _controller.forward();
                }
              }
            });
          }

          setState(() {
            _orbitAngle += _angleIncrement;
            if (_orbitAngle >= 2 * pi) {
              _orbitAngle -= 2 * pi;
            }
          });
        }
      });
    });
  }

  double get centerX => MediaQuery.of(context).size.width / 2;
  double get centerY => MediaQuery.of(context).size.height / 4;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _isSatelliteInPlace() {
    double satelliteCenterX = centerX;
    double satelliteCenterY = _yPosition;
    double targetX = centerX + _orbitRadius * cos(_orbitAngle);
    double targetY = centerY + _orbitRadius * sin(_orbitAngle);

    double toleranceRadius = 18.75;
    double distance = sqrt(pow(satelliteCenterX - targetX, 2) +
        pow(satelliteCenterY - targetY, 2));

    return distance <= toleranceRadius;
  }

  Color getPullBarColor() {
    if (_dragDistance > MediaQuery.of(context).size.height / 4) {
      return Colors.red;
    } else if (_dragDistance > MediaQuery.of(context).size.height / 8) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double targetX = centerX + _orbitRadius * cos(_orbitAngle);
    double targetY = centerY + _orbitRadius * sin(_orbitAngle);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Image.asset('assets/png/space.jpeg',
              width: size.width, height: size.height, fit: BoxFit.cover),
          Positioned(
            top: centerY - 37.5,
            left: centerX - 37.5,
            child: Lottie.asset(
              'assets/lottie/earth.json',
              width: 75,
              height: 75,
            ),
          ),
          CustomPaint(
            painter: OrbitPainter(),
            child: Container(),
          ),
          Positioned(
            left: targetX - 18.75,
            top: targetY - 18.75,
            child: Lottie.asset(
              _hasWon
                  ? 'assets/lottie/satellite.json'
                  : 'assets/lottie/satellite_point.json',
              width: 37.5,
              height: 37.5,
            ),
          ),
          if (_isSatelliteVisible)
            Positioned(
              left: centerX - 18.75,
              top: _yPosition - 18.75,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dragDistance += details.delta.dy;
                    _dragDistance = _dragDistance.clamp(0, size.height / 2);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isSatelliteLaunched = true;
                    _yVelocity = -_dragDistance / 10;
                    _dragDistance = 0;
                  });
                },
                child: Transform.translate(
                  offset: Offset(0, _dragDistance),
                  child: Lottie.asset(
                    'assets/lottie/satellite.json',
                    width: 37.5,
                    height: 37.5,
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Row(
              children: List.generate(
                _attempts,
                (index) => const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              width: 20,
              height: size.height / 3,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: _dragDistance.clamp(0, size.height / 3),
                      color: getPullBarColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_isGameStarted && !_hasWon && !_hasLost)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Oyun Direktifleri',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Uyduyu aşağı çekip bırakın.\n\n'
                      'Uydu yörüngedeki uydu ile çakıştığında kazanın.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isGameStarted = true;
                        });
                      },
                      child: const Text('Başlat'),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasWon)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tebrikler, kazandınız!',
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Harika bir iş çıkardınız!\n'
                      'Altın ödülünüzü kazandınız!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasLost)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Üzgünüm, kaybettiniz',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Harika bir iş çıkardınız!\n'
                      'Daha güzel ödüller için haftaya tekrar deneyin!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(String title, String message, Color color) {
    return Container(
      alignment: Alignment.bottomCenter,
      color: color,
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Reset the game
              setState(() {
                _isGameStarted = false;
                _hasWon = false;
                _hasLost = false;
                _attempts = 3;
                _yPosition = MediaQuery.of(context).size.height / 1.5;
                _isSatelliteVisible = true;
              });
            },
            child: const Text('Yeniden Oyna'),
          ),
        ],
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double centerX = size.width / 2;
    double centerY = size.height / 4;
    double radius = 90;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
