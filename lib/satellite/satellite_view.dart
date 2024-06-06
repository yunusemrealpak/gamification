import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SatelliteView extends StatefulWidget {
  const SatelliteView({super.key});

  @override
  State<SatelliteView> createState() => _SatelliteViewState();
}

class _SatelliteViewState extends State<SatelliteView>
    with SingleTickerProviderStateMixin {
  double _xPosition = 0;
  double _yPosition = 0;
  double _xVelocity = 0;
  double _yVelocity = 0;
  static const double _friction = 0.9;
  static const double _accelerationFactor = 0.35;
  Timer? _timer;

  double _orbitAngle = 0;
  static const double _orbitRadius = 180;
  static const double _angleIncrement = 0.01;

  bool _isGameStarted = false;
  bool _hasWon = false;
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

    Sensors().accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted && _isGameStarted) {
        setState(() {
          _xVelocity -= event.x * _accelerationFactor;
          _yVelocity -= event.y * _accelerationFactor;
        });
      }
    });

    Future.microtask(() {
      final size = MediaQuery.of(context).size;
      Random random = Random();
      _xPosition = random.nextDouble() * 100 - 100;
      _yPosition = size.height / 4 + random.nextDouble() * 100;

      _timer = Timer.periodic(const Duration(milliseconds: 16), (e) {
        if (mounted && _isGameStarted) {
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

          double targetX =
              centerX + _orbitRadius * cos(_orbitAngle) - size.width * 0.1;
          double targetY = centerY +
              _orbitRadius * sin(_orbitAngle) +
              MediaQuery.of(context).size.height * 0.25;

          if (_isSatelliteInPlace(targetX, targetY)) {
            if (!_hasWon) {
              setState(() {
                _hasWon = true;
              });
            }
            _controller.forward();
          }
        }
      });
    });
  }

  double get centerX => MediaQuery.of(context).size.width / 2;
  double get centerY => MediaQuery.of(context).size.height / 2;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _isSatelliteInPlace(double targetX, double targetY) {
    double satelliteCenterX = centerX + _xPosition;
    double satelliteCenterY = centerY - _yPosition;
    double targetCenterX = targetX;
    double targetCenterY = targetY;

    // Log the positions for debugging
    print("Satellite: $satelliteCenterX, $satelliteCenterY");
    print("Target: $targetCenterX, $targetCenterY");

    // Tolerans yarıçapı: 75x75 boyutundaki Lottie animasyonlarının yarıçapı 37.5
    double toleranceRadius = 37.5;

    // İki nokta arasındaki mesafeyi hesapla
    double distance = sqrt(pow(satelliteCenterX - targetCenterX, 2) +
        pow(satelliteCenterY - targetCenterY, 2));

    // Mesafe tolerans yarıçapından küçük veya eşitse çakışma var demektir
    return distance <= toleranceRadius;
  }

  double _calculateAngle(double fromX, double fromY, double toX, double toY) {
    return atan2(toY - fromY, toX - fromX);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double targetX =
        centerX + _orbitRadius * cos(_orbitAngle) - size.width * 0.1;
    double targetY =
        centerY + _orbitRadius * sin(_orbitAngle) + size.height * 0.25;

    double earthCenterX = centerX;
    double earthCenterY = centerY + size.height * 0.375;

    double angle =
        _calculateAngle(targetX, targetY, earthCenterX, earthCenterY);

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
          Image.asset('assets/png/space.jpeg',
              width: size.width, height: size.height, fit: BoxFit.cover),
          Positioned(
            bottom: size.height * 0.125,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/lottie/earth.json',
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            left: targetX,
            top: targetY,
            child: !_hasWon
                ? Transform.rotate(
                    angle: angle,
                    child: Lottie.asset(
                      'assets/lottie/satellite_point.json',
                      width: 75,
                      height: 75,
                    ),
                  )
                : Transform.rotate(
                    angle: angle,
                    child: Lottie.asset(
                      'assets/lottie/satellite.json',
                      width: 75,
                      height: 75,
                    ),
                  ),
          ),
          if (!_hasWon)
            Positioned(
              left: centerX + _xPosition,
              top: centerY - _yPosition,
              child: Lottie.asset(
                'assets/lottie/satellite.json',
                width: 75,
                height: 75,
              ),
            ),
          if (!_isGameStarted && !_hasWon)
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
                      'Telefonu hareket ettirerek uyduyu yörüngeye oturtun.\n\n'
                      'Uydu, beyaz uyduyla eşleştirildiğinde ödül kazanacaksınız.',
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
            SlideTransition(
              position: _offsetAnimation,
              child: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.green,
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'Tebrikler! Kazandınız!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
