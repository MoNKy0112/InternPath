import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/data/firebase/firebase_auth_service.dart';
import 'package:internpath/data/repositories/user_repository_impl.dart';
import 'package:internpath/domain/repositories/user_repository.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  //Controladores para los campos de texto
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late final AuthUseCases _authUseCases;

  @override
  void initState() {
    super.initState();
    final authService = FirebaseAuthService();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final UserRepository userRepository = UserRepositoryImpl(
      authService,
      firestore,
    );
    _authUseCases = AuthUseCases(userRepository);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  //Global key para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    // Implement your register logic here
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    try {
      await _authUseCases.registerWithEmailAndPassword(
        fullName,
        email,
        password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error en el registro: $e')));
    }
  }

  void routeLogin() {
    // Implement your navigation to login screen here
    context.go('/login');
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
                  Text(
                    'Registro',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Padding(padding: const EdgeInsets.only(top: 10)),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                    ),
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
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                  ),
                  Padding(padding: const EdgeInsets.only(top: 20)),
                  ElevatedButton(
                    onPressed: register,
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 1.0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: routeLogin,
                    child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
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
