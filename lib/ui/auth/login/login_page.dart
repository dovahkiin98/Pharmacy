import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy/app.dart';
import 'package:pharmacy/utils/utils.dart';
import 'package:provider/provider.dart';

import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(context),
      builder: (context, child) {
        return _LoginPage();
      },
    );
  }
}

class _LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  late final controller = context.watch<LoginController>();
  bool showPassword = false;

  late final emailTextController = controller.emailTextController;
  late final passwordTextController = controller.passwordTextController;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom != 0;

    return Scaffold(
      body: ListView(
        padding: viewPadding + const EdgeInsets.all(16),
        children: [
          if (kDebugMode)
            DefaultTabController(
              length: 2,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Admin'),
                  Tab(text: 'User'),
                ],
                onTap: (tab) {
                  if (tab == 0) {
                    emailTextController.text = 'admin@admin.com';
                    passwordTextController.text = '12345678';
                  } else if (tab == 1) {
                    emailTextController.text = 'user@user.com';
                    passwordTextController.text = '12345678';
                  }
                },
              ),
            ),
          GestureDetector(
            onLongPress: kDebugMode
                ? () {
              // Show a dialog to change Firebase IP without needing to rebuild the application.
                    showDialog(
                      context: context,
                      builder: (context) {
                        final textController = TextEditingController(text: controller.getIP());

                        return AlertDialog(
                          title: const Text('Change IP'),
                          content: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              hintText: 'Firebase IP',
                              labelText: 'Firebase IP',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(textController.text);
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      if (value is String) {
                        controller.updateIP(value);
                      }
                    });
                  }
                : null,
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: emailTextController,
            decoration: const InputDecoration(
              hintText: 'Email',
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            style: TextStyle(
              color: controller.loading ? Theme.of(context).disabledColor : null,
            ),
            textInputAction: TextInputAction.next,
            maxLines: 1,
            enabled: !controller.loading,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: passwordTextController,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            style: TextStyle(
              color: controller.loading ? Theme.of(context).disabledColor : null,
            ),
            textInputAction: TextInputAction.done,
            maxLines: 1,
            enabled: !controller.loading,
            onSubmitted: (value) {
              login();
            },
            obscureText: !showPassword,
          ),
          const SizedBox(height: 24),
          if (controller.loading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: const Text('Login'),
            ),
        ],
      ),
    );
  }

  bool validateInput() {
    final emailValue = controller.emailTextController.text;
    final passwordValue = controller.passwordTextController.text;

    if (emailValue.trim().isEmpty || !EmailValidator.validate(emailValue)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid Email'),
        showCloseIcon: true,
      ));

      return false;
    } else if (passwordValue.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Empty Password'),
        showCloseIcon: true,
      ));

      return false;
    }

    return true;
  }

  login() async {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).clearSnackBars();

    if (validateInput()) {
      try {
        await controller.login();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Login Successful!'),
            showCloseIcon: true,
          ));

          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.HOME);
        }
      } on Exception catch (e) {
        String message = getErrorText(e);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          showCloseIcon: true,
        ));
      }
    }
  }
}
