import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:nutricook/firebase_options.dart';
import 'package:nutricook/seed/database_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('SEED: initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('SEED: running DatabaseSeeder.seed()...');
  await DatabaseSeeder.seed();
  print('SEED: completed successfully.');
}
