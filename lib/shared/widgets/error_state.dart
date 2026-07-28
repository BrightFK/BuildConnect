import 'package:artisan/export.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.body1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(text: 'Retry', onPressed: onRetry, isOutlined: true),
        ],
      ),
    );
  }
}
