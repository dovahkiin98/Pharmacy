import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

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
