import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/constants.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p28,
          horizontal: AppSizes.p32,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.r20),
          boxShadow: [
            BoxShadow(
              color: AppColors.dialogShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: AppSizes.p20),
            Text(
              AppStrings.analyzing,
              style: AppTextStyles.dialogTitle,
            ),
            SizedBox(height: AppSizes.p4),
            Text(
              AppStrings.backgroundProcess,
              style: AppTextStyles.dialogSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
