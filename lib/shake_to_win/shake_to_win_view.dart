import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeToWinView extends StatefulWidget {
  const ShakeToWinView({super.key});

  @override
  _ShakeToWinViewState createState() => _ShakeToWinViewState();
}

class _ShakeToWinViewState extends State<ShakeToWinView> {
  List<String> rewards = ["Reward 1", "Reward 2", "Reward 3", "Reward 4"];
  Random random = Random();
  int shakeCount = 0;
  double shakeThresholdGravity = 2.7;
  bool shakeInProgress = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double gX = event.x / 9.81;
      double gY = event.y / 9.81;
      double gZ = event.z / 9.81;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThresholdGravity) {
        if (!shakeInProgress) {
          shakeInProgress = true;
          onShake();
          Future.delayed(const Duration(seconds: 1), () {
            shakeInProgress = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void onShake() {
    setState(() {
      shakeCount++;
    });
    int rewardIndex = random.nextInt(rewards.length);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You won ${rewards[rewardIndex]}!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (shakeCount < 5) {
                  onReplay();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void onReplay() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Play Again?'),
          content: const Text('Shake your phone to win more rewards!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake to Win'),
      ),
      body: const Center(
        child: Text(
          'Shake your phone to win a reward!',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
