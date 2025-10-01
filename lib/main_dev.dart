import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internpath/core/dependency_injection.dart';
import 'package:internpath/firebase_options.dart';
import 'package:internpath/main.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: DependencyInjection.buildProviders(),
      child: const MyApp(),
      // child: const MyApp(flavor: "dev"),
    ),
  );
}
