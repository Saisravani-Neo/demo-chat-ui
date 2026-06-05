import 'package:agorachat/app/routes.dart';
import 'package:flutter/material.dart';

import 'core/storage/local_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.init();

  runApp(const RegisterApp());
}

class RegisterApp extends StatelessWidget {
  const RegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}