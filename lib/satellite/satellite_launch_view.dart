import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamification/widgets/listen.dart';
import 'package:lottie/lottie.dart';

class SatelliteLaunchView extends StatefulWidget {
  const SatelliteLaunchView({super.key});

  @override
  State<SatelliteLaunchView> createState() => _SatelliteLaunchViewState();
}

class _SatelliteLaunchViewState extends State<SatelliteLaunchView> {
  final GlobalKey _rocketKey = GlobalKey();
  final GlobalKey _point1Key = GlobalKey();
  final GlobalKey _point2Key = GlobalKey();

  Timer? _timer;
  final ValueNotifier<bool> _isGameStarted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLaunched = ValueNotifier<bool>(false);

  double _x1 = 0;
  final double _y1 = 100;

  double _x2 = 0;
  final double _y2 = 100;
  double _rocketY = 20;

  double _orbitAngle = 0;
  static const double _maxOrbitAngle = 6;

  final double _dx = 2;
  double _dy = 0;

  double _power = 0;
  static const double _maxPower = 100;
  bool _isDragging = false;
  bool _canLaunch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_update);
  }

  void _update() {
    _x2 = MediaQuery.of(context).size.width / 2 + 100;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (Timer e) {
      setState(() {
        _x1 += _dx;
        _x2 += _dx;

        Size size = MediaQuery.of(context).size;

        _orbitAngle = _maxOrbitAngle * sin(_x1 / size.width * 1 * pi);

        if (_x1 - 50 > size.width) {
          _x1 = -50;
        }

        if (_x2 - 50 > size.width) {
          _x2 = -50;
        }

        if (!_isDragging && _isGameStarted.value) {
          if (_power > 0) {
            _dy = _power / 10; // Power consumption rate
            _power -= 0.25; // Increase power consumption rate
          }

          if (_canLaunch) {
            _dy -= 0.05; // Gravity
            _rocketY += _dy;
            _checkCollision();
          }

          if (_rocketY < -50 || _rocketY > size.height + 50) {
            reset();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkCollision() {
    RenderBox rocketBox =
        _rocketKey.currentContext!.findRenderObject() as RenderBox;
    RenderBox point1Box =
        _point1Key.currentContext!.findRenderObject() as RenderBox;
    RenderBox point2Box =
        _point1Key.currentContext!.findRenderObject() as RenderBox;

    Offset rocketPosition =
        rocketBox.localToGlobal(rocketBox.size.center(Offset.zero));
    Offset pointPosition =
        point1Box.localToGlobal(point1Box.size.center(Offset.zero));
    Offset point2Position =
        point2Box.localToGlobal(point2Box.size.center(Offset.zero));

    double distance = sqrt(pow(rocketPosition.dx - pointPosition.dx, 2) +
        pow(rocketPosition.dy - pointPosition.dy, 2));
    double distance2 = sqrt(pow(rocketPosition.dx - point2Position.dx, 2) +
        pow(rocketPosition.dy - point2Position.dy, 2));

    if (distance < 30 || distance2 < 30) {
      reset();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kazandınız!'),
          content: const Text('Roket başarıyla yerleşme noktasına ulaştı.'),
          actions: [
            ElevatedButton(
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

  void reset() {
    _x1 = 100;
    _rocketY = 20;
    _orbitAngle = 0;
    _dy = 0;
    _power = 0;
    _isDragging = false;
    _canLaunch = false;
    _isGameStarted.value = false;
    _isLaunched.value = false;
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _power = 0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _power = (details.localPosition.dy / 450 * _maxPower).clamp(0, _maxPower);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dy = _power / 10;
      _canLaunch = true;
      _isLaunched.value = true;
    });
  }

  Color _getPowerColor() {
    if (_power < 33) {
      return Colors.yellow;
    } else if (_power < 66) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Positioned(
                      left: _x1,
                      top: _y1 - _orbitAngle,
                      child: CircleAvatar(
                        key: _point1Key,
                        radius: 10,
                        backgroundColor: Colors.red,
                      ),
                    ),
                    Positioned(
                      left: _x2,
                      top: _y2 - _orbitAngle,
                      child: CircleAvatar(
                        key: _point2Key,
                        radius: 10,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Text('Drag to launch'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: _rocketY,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: Listen(
              notifier: _isGameStarted,
              builder: (context, value, _) => Transform.rotate(
                angle: value ? (_dy > 0 ? 0 : -_dy / 10) : 0,
                origin: const Offset(0, 10),
                child: Icon(
                  key: _rocketKey,
                  Icons.rocket,
                  size: 50,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: Center(
              child: Listen(
                notifier: _isLaunched,
                builder: (context, value, _) {
                  if (!value) return const SizedBox();
                  return Lottie.asset(
                    'assets/lottie/smoke.json',
                    width: 125,
                    repeat: false,
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 50,
            child: Container(
              height: 200,
              width: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: (_power * 2 < 0) ? 0 : (_power * 2).clamp(0, 200),
                      width: 30,
                      decoration: BoxDecoration(
                        color: _getPowerColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: _isGameStarted,
              builder: (context, value, child) {
                return value
                    ? const SizedBox()
                    : Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Satellite Launch',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Drag to launch the satellite',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'You can adjust the power by dragging up and down',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _isGameStarted.value = true;
                                },
                                child: const Text('Start Game'),
                              )
                            ],
                          ),
                        ),
                      );
              }),
        ],
      ),
    );
  }
}
