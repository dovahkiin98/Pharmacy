import 'package:flutter/material.dart';
import 'package:pharmacy/utils/utils.dart';

class ErrorView extends StatelessWidget {
  final Object error;

  const ErrorView({
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          getErrorText(error),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
