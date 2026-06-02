import 'package:flutter/material.dart';
import 'Screens/Home.dart';
import 'service/daily_reset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DailyResetService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF283593)),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}
