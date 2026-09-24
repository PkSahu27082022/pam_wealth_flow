import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class Alert {
  static void show(
    BuildContext context, {
    required String message,
    String? errorDetail,
    AlertType type = AlertType.error,
  }) {
    // Suppress technical details in production for errors if no specific message provided
    String displayMessage = message;
    if (type == AlertType.error && message.isEmpty) {
      displayMessage = "Something went wrong. Please try again after some time.";
    }

    if (kDebugMode && errorDetail != null) {
      print("DEBUG ERROR DETAIL: $errorDetail");
    }

    Color bgColor;
    IconData icon;

    switch (type) {
      case AlertType.success:
        bgColor = const Color(0xFF2D6A4F);
        icon = Icons.check_circle_outline;
        break;
      case AlertType.warning:
        bgColor = const Color(0xFFB8860B);
        icon = Icons.warning_amber_rounded;
        break;
      case AlertType.info:
        bgColor = const Color(0xFF1B4965);
        icon = Icons.info_outline;
        break;
      case AlertType.error:
      default:
        bgColor = const Color(0xFFC72C41);
        icon = Icons.error_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTitle(type),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getTitle(AlertType type) {
    switch (type) {
      case AlertType.success: return "Success";
      case AlertType.warning: return "Warning";
      case AlertType.info: return "Information";
      case AlertType.error: return "Error";
    }
  }
}
