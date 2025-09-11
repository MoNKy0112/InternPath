import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
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

  //Parametros extras para customizar el Scaffold
  final Map<String, dynamic> scaffoldExtras;

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: scaffoldExtras['floatingActionButton'] as Widget?,
      floatingActionButtonLocation:
          scaffoldExtras['floatingActionButtonLocation']
              as FloatingActionButtonLocation?,
      floatingActionButtonAnimator:
          scaffoldExtras['floatingActionButtonAnimator']
              as FloatingActionButtonAnimator?,
      backgroundColor: scaffoldExtras['backgroundColor'] as Color?,
    );
  }
}
