import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Service Locator & Local Storage
  await initDependencies();

  runApp(const MyApp());
}
