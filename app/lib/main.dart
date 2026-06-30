import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() => runApp(const MyBodyRpgApp());

class MyBodyRpgApp extends StatelessWidget {
  const MyBodyRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBody:RPG',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: appState,
        builder: (context, _) =>
            appState.onboarded ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }
}
