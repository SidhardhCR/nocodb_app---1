import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nocodb_app/pages/BaseScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NocoDB App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BaseScreen(workspaceId: dotenv.env['WORKSPACE_ID']!),
    );
  }
}
