import 'package:flutter/material.dart';
import 'package:internpath/presentation/screens/user/register/components/register_form.dart';
import 'package:internpath/presentation/widgets/logo_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isKeyboardOpen) LogoWidget(size: 100, showName: true),
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}
