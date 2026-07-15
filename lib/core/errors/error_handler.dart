import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../errors/app_exception.dart';

/// Utility terpusat untuk menampilkan error kepada user.
/// Semua feedback error harus menggunakan kelas ini agar konsisten.
class ErrorHandler {
  ErrorHandler._(); // Prevent instantiation

  /// Tampilkan SnackBar untuk error ringan (non-fatal).
  static void showSnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    bool isWarning = false,
  }) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isWarning ? Icons.warning_amber_rounded : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isWarning ? AppColors.orange : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Tampilkan SnackBar dari [AppException].
  static void showFromException(
    ScaffoldMessengerState messenger,
    AppException exception,
  ) {
    final isWarning = exception.type == AppErrorType.noInternet ||
        exception.type == AppErrorType.timeout ||
        exception.type == AppErrorType.modelNotLoaded;

    showSnackBar(messenger, exception.userMessage, isWarning: isWarning);
  }

  /// Tampilkan AlertDialog untuk error yang memerlukan tindakan user.
  static Future<void> showDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCancel = false,
  }) {
    return showAdaptiveDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: AppColors.redAccent,
          size: 40,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (showCancel)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onAction?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(actionLabel ?? 'OK'),
          ),
        ],
      ),
    );
  }
}
