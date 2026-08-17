import 'package:flutter/material.dart';

/// Temporary placeholder for screens not yet implemented.
/// Lets Home Screen navigation work without crashing, without
/// pretending those screens are actually built.
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "$title is coming in the next milestone.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
