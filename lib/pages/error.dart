import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object error;
  final StackTrace? stack;

  const ErrorPage({super.key, required this.error, this.stack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $error\n\n${stack ?? ''}'),
        ),
      ),
    );
  }
}
