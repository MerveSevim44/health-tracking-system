import 'package:flutter/material.dart';
import 'package:health_care/screens/home_screen.dart';
import 'package:health_care/widgets/theme.dart';
import 'package:provider/provider.dart';
import 'models/mood_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duygu Durumu',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // <<< GÜNCELLENDİ: Oluşturduğumuz temayı kullan
      home: const HomeScreen(),
    );
  }
}