import 'package:flutter/material.dart';
import 'package:internpath/presentation/screens/login/components/login_form.dart';
import 'package:internpath/presentation/widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoWidget(),
            Text(
              'InternPath',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}
