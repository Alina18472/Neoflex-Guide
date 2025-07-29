import 'package:flutter/material.dart';
import 'package:flutter_application_neoflex/database/database_helper.dart';
import 'package:flutter_application_neoflex/home_screen.dart';
import 'package:flutter_application_neoflex/user_state.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // await DatabaseHelper().deleteDatabase();
  await DatabaseHelper().database;
 
  final userState = UserState();
  await userState.loadFromPrefs();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => userState,
      child: const NeoFlexQuestApp(),
    ),
  );
}

class NeoFlexQuestApp extends StatelessWidget {
  const NeoFlexQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoFlex Quest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}