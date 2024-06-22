import 'package:flutter/material.dart';

class Listen<T> extends StatelessWidget {
  final ValueNotifier<T> notifier;
  final Widget Function(BuildContext, T, Widget?) builder;
  const Listen({super.key, required this.notifier, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: builder,
    );
  }
}
