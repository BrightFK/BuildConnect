import 'package:artisan/export.dart';
import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;

  const RefreshButton({super.key, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh, color: color ?? AppColors.textPrimary),
      onPressed: onPressed,
      tooltip: 'Refresh',
    );
  }
}
