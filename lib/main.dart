import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bloc_observer.dart';
import 'src/container_injector.dart';
import 'src/my_app.dart';
import 'starterkit_init.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If it's already initialized, we can safely ignore the error
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Initialize StarterKit
  await initializeStarterKit();

  // Initialize app dependencies
  initApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
