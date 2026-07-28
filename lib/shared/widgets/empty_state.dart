import 'package:flutter/material.dart';

import '../../core/theme/typography.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.body1,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            AppButton(text: 'Retry', onPressed: onRetry!, isOutlined: true),
          ],
        ],
      ),
    );
  }
}
