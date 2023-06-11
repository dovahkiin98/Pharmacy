import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmacy/data/repository.dart';
import 'package:provider/provider.dart';

class LoginController extends ChangeNotifier {
  final Repository _repository;

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool _loading = false;

  bool get loading => _loading;

  LoginController(BuildContext context) : _repository = context.read() {
    if (kDebugMode) {
      emailTextController.text = 'ahmad.sattout.ee@outlook.com';
      passwordTextController.text = '12345678';
    }
  }

  login() async {
    _loading = true;

    notifyListeners();

    try {
      await _repository.login(
        emailTextController.text.trim(),
        passwordTextController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      rethrow;
    } finally {
      _loading = false;

      notifyListeners();
    }
  }
}
