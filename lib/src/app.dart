import 'package:flutter/material.dart';

import 'learning_home_page.dart';

class KiCampusCompanionApp extends StatelessWidget {
  const KiCampusCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KI-Campus Companion',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const LearningHomePage(),
    );
  }
}
