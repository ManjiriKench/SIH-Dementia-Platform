import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BackendTestScreen(),
    );
  }
}

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  String message = 'Testing backend...';

  @override
  void initState() {
    super.initState();
    testConnection();
  }

  Future<void> testConnection() async {
    final result = await ApiService.testBackend();

    if (!mounted) return;

    setState(() {
      message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dementia Assist'),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}