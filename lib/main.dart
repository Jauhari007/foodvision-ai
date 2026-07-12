import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FoodVisionAI());
}

class FoodVisionAI extends StatelessWidget {
  const FoodVisionAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodVision AI',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}