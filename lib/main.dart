import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'pages/home/home_page.dart';
import 'providers/prediction_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: const FoodVisionAI(),
    ),
  );
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