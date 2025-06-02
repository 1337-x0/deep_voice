import 'package:flutter/material.dart';
import 'package:deep_voice_transformer/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:deep_voice_transformer/providers/audio_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
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
      title: 'Deep Voice Transformer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.purpleAccent,
          secondary: Colors.blueAccent,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.purpleAccent,
          inactiveTrackColor: Colors.grey[800],
          thumbColor: Colors.purpleAccent,
          overlayColor: Colors.purpleAccent.withOpacity(0.3),
          valueIndicatorColor: Colors.purpleAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
