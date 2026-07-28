// Not needed if we have role dropdown on register.
// But we'll keep a minimal stub for completeness.
import 'package:flutter/material.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Choose Role (handled in register)')),
    );
  }
}
