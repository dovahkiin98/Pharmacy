import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String getErrorText(dynamic e) {
  if (e is FirebaseAuthException) {
    return e.message ?? e.toString();
  } else if (e is TimeoutException) {
    return 'Internet connectivity is limited or unavailable';
  } else if (e is Error) {
    return e.toString();
  } else {
    return e.toString();
  }
}

Color getQualityColor(int quality) {
  switch (quality) {
    case 1:
    case 2:
    case 3:
      return Colors.red;
    case 4:
    case 5:
    case 6:
      return Colors.yellow;
    case 7:
    case 8:
      return Colors.green;
    case 9:
    case 10:
      return Colors.blue;
    default:
      return Colors.red;
  }
}
