import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bloc_observer.dart';
import 'src/container_injector.dart';
import 'src/my_app.dart';
import 'starter_kit/starter_kit.dart';
import 'starter_kit/features/analytics/presentation/bloc/analytics_event.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize StarterKit (Analytics, Ads, IAP, Services)
  await StarterKit.initialize();
  
  // Initialize analytics
  StarterKit.analyticsBloc.add(const AnalyticsInitialize());
  
  // Initialize app dependencies
  initApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
