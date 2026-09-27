import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class Alert {
  /// Floating SnackBar Banner
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
                color: Colors.black.withValues(alpha: 0.3),
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

  /// Common Reusable Modal Alert Dialog
  static Future<void> showPopup(
    BuildContext context, {
    required String title,
    required String message,
    AlertType type = AlertType.info,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    Color iconColor;
    IconData icon;

    switch (type) {
      case AlertType.success:
        iconColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_rounded;
        break;
      case AlertType.warning:
        iconColor = const Color(0xFFFFC107);
        icon = Icons.warning_rounded;
        break;
      case AlertType.info:
        iconColor = const Color(0xFF2196F3);
        icon = Icons.info_rounded;
        break;
      case AlertType.error:
      default:
        iconColor = const Color(0xFFE57373);
        icon = Icons.error_rounded;
        break;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF171920),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF50525A), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFDDB83A),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (onPressed != null) onPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDDB83A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
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
