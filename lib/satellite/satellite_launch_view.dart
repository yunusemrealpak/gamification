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
  static const double _accelerationFactor = 0.1;
  Timer? _timer;

  double _orbitAngle = 0;
  static const double _orbitRadius = 180;
  static const double _angleIncrement = 0.01;

  bool _isGameStarted = false;
  bool _isSatelliteLaunched = false;
  bool _hasWon = false;
  bool _hasLost = false;
  int _attempts = 3;
  bool _isSatelliteVisible = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

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
      _yPosition = size.height - 75;

      _timer = Timer.periodic(const Duration(milliseconds: 16), (e) {
        if (mounted && _isGameStarted) {
          if (_isSatelliteLaunched) {
            setState(() {
              _yPosition += _yVelocity;
              _yVelocity -= _accelerationFactor;

              if (_yPosition <= 0) {
                _attempts--;
                _yVelocity = 0;
                _yPosition = size.height - 75;
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

    double toleranceRadius = 37.5;
    double distance = sqrt(pow(satelliteCenterX - targetX, 2) +
        pow(satelliteCenterY - targetY, 2));

    return distance <= toleranceRadius;
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
            top: centerY - 75,
            left: centerX - 75,
            child: Lottie.asset(
              'assets/lottie/earth.json',
              width: 150,
              height: 150,
            ),
          ),
          CustomPaint(
            painter: OrbitPainter(),
            child: Container(),
          ),
          Positioned(
            left: targetX - 37.5,
            top: targetY - 37.5,
            child: Lottie.asset(
              _hasWon
                  ? 'assets/lottie/satellite.json'
                  : 'assets/lottie/satellite_point.json',
              width: 75,
              height: 75,
            ),
          ),
          if (_isSatelliteVisible)
            Positioned(
              left: centerX - 37.5,
              top: _yPosition - 37.5,
              child: Lottie.asset(
                'assets/lottie/satellite.json',
                width: 75,
                height: 75,
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
                      'Fırlatma ikonuna tıklayarak uyduyu fırlatın.\n\n'
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
          if (_isGameStarted && !_hasWon && !_hasLost && !_isSatelliteLaunched)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isSatelliteLaunched = true;
                    _yVelocity = -5;
                  });
                },
                child: const Icon(Icons.rocket_launch),
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
                _yPosition = MediaQuery.of(context).size.height - 75;
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
    double radius = 180;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
