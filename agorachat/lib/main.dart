import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/storage/local_storage.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.init();

  // In debug builds wipe stored session so every cold-start begins at Register.
  // Remove this block (or set to false) when the real backend is integrated.
  if (kDebugMode) {
    await LocalStorage.clearAll();
  }

  runApp(const App());
}
