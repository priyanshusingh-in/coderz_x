import 'package:flutter/material.dart';
import 'error_handler.dart';

class GlobalErrorWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const GlobalErrorWidget({
    super.key, 
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildErrorIcon(error.type),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(error.type),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon(ErrorType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ErrorType.network:
        icon = Icons.signal_wifi_off;
        color = Colors.orange;
        break;
      case ErrorType.authentication:
        icon = Icons.lock_outline;
        color = Colors.red;
        break;
      case ErrorType.database:
        icon = Icons.storage;
        color = Colors.purple;
        break;
      case ErrorType.validation:
        icon = Icons.warning_amber_rounded;
        color = Colors.yellow;
        break;
      case ErrorType.permission:
        icon = Icons.block;
        color = Colors.grey;
        break;
      default:
        icon = Icons.error_outline;
        color = Colors.red;
    }

    return Icon(
      icon,
      size: 100,
      color: color,
    );
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.authentication:
        return 'Authentication Failed';
      case ErrorType.database:
        return 'Database Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.permission:
        return 'Permission Denied';
      default:
        return 'Unexpected Error';
    }
  }
}
