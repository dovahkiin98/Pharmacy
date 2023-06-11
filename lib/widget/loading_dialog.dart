import 'package:flutter/material.dart';

class LoadingDialog extends AlertDialog {
  final Future future;
  final String message;

  const LoadingDialog({
    required this.future,
    required this.message,
    super.key,
  });

  @override
  Widget? get content => FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          Navigator.pop(context, snapshot.error);
        } else if (snapshot.connectionState != ConnectionState.waiting) {
          Navigator.pop(context, snapshot.data);
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$message...",
              maxLines: 2,
            ),
          ),
        ],
      );
    },
  );

  @override
  EdgeInsets get insetPadding => const EdgeInsets.all(24);
}
