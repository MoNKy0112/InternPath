import 'package:flutter/material.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ModderRegistrationScreen extends StatefulWidget {
  const ModderRegistrationScreen({super.key});

  @override
  State<ModderRegistrationScreen> createState() =>
      _ModderRegistrationScreenState();
}

class _ModderRegistrationScreenState extends State<ModderRegistrationScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  String? errorMessage;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final auth = context.read<AuthUseCases>();
    try {
      // registerModder debe encargarse internamente de crear el usuario
      // sin alterar la sesión actual del admin y de crear el perfil de dominio.
      await auth.registerModder(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modder registrado correctamente')),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al registrar usuario: $e';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // preferir Navigator.pop, fallback a GoRouter
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                router.go('/');
              }
            }
          },
        ),
        title: const Text('Registrar modder'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Crear cuenta de Modder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rellena los datos para crear un modder. Se asignará el rol "modder" al usuario.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Nombre completo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Requerido'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Email inválido'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Min 6 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage != null) ...[
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Registrar modder'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
