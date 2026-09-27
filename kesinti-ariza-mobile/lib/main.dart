import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod'u içe aktardık
import 'package:kesinti_ariza_mobile/screens/auth/login_screen.dart'; // Yaptığımız login ekranını içe aktardık

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kesinti ve Arıza Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00529B)),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}