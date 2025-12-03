import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/presentation/widgets/profile_bottom_sheet.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    required this.currentPageIndex,
    this.scaffoldExtras = const {},
  });

  final String title;
  final Widget child;
  final int currentPageIndex;
  final Map<String, dynamic> scaffoldExtras;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _showProfileSheet = false;

  void _onItemTapped(BuildContext context, int index) {
    // Siempre cerramos el sheet cuando se cambia de pestaña
    if (index != 2 && _showProfileSheet) {
      setState(() => _showProfileSheet = false);
    }

    // determinar homeRoute dinámicamente: prioridad scaffoldExtras, si no, según rol
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String homeRoute =
        (widget.scaffoldExtras['homeRoute'] as String?) ??
        (authProvider.isModder ? '/requests' : '/');

    switch (index) {
      case 0:
        context.go(homeRoute);
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        // En lugar de navegar, mostramos/ocultamos el BottomSheet encima
        setState(() => _showProfileSheet = !_showProfileSheet);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          widget.child,
          if (_showProfileSheet)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showProfileSheet = false;
                });
              },
              child: Container(
                color: Colors.black54, // fondo oscuro
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ProfileBottomSheet(
              offset: _showProfileSheet
                  ? const Offset(0, 0)
                  : const Offset(0, 1),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.currentPageIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: widget.scaffoldExtras['floatingActionButton'],
    );
  }
}
