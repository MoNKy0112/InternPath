import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/domain/entities/user_role.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  //Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthUseCases _authUseCases;

  //Global key para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final user = await _authUseCases.signInWithEmailAndPassword(
        email,
        password,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bienvenido ${user.fullName}")));

      // navegar según rol: si es modder -> requests, si no -> home (experiences)
      final isModder = user.role == UserRole.modder;
      if (isModder) {
        context.go('/requests');
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al iniciar sesión: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void forgotPassword() {
    // Implement your forgot password logic here
    context.go('/reset-password');
  }

  void routeSignUp() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 8,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: forgotPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  TextButton(
                    onPressed: routeSignUp,
                    child: const Text('¿No tienes una cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
