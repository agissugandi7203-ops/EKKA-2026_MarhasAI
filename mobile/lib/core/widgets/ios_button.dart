import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Tombol utama kustom bergaya iOS (stadium shape).
///
/// Menyediakan visualisasi tombol Cupertino dengan sudut membulat penuh,
/// loading indicator, disabled state, serta ikon pendukung.
class IosButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isFilled;
  final Color? backgroundColor;
  final Color? textColor;

  const IosButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFilled = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final themeColor = backgroundColor ?? (isFilled ? const Color(0xFF007AFF) : Colors.transparent);
    final textThemeColor = textColor ?? (isFilled ? Colors.white : const Color(0xFF007AFF));

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: isFilled ? themeColor : null,
        disabledColor: isFilled 
            ? (isLoading ? themeColor : Colors.grey.shade300) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        onPressed: isDisabled ? null : onPressed,
        child: Container(
          decoration: !isFilled
              ? BoxDecoration(
                  border: Border.all(
                    color: isLoading 
                        ? themeColor 
                        : themeColor.withValues(alpha: 0.5), 
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(26),
                )
              : null,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: Lottie.asset(
                    'assets/animations/global/global_loading.json',
                    fit: BoxFit.contain,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (isDisabled && !isLoading) && isFilled 
                            ? Colors.grey.shade600 
                            : textThemeColor,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Widget layout pembungkus untuk dua tombol di bagian bawah (Stacked CTA + Back).
class IosBottomButtons extends StatelessWidget {
  final String nextText;
  final VoidCallback? onNextPressed;
  final bool isNextLoading;
  final bool isNextEnabled;
  final String backText;
  final VoidCallback? onBackPressed;

  const IosBottomButtons({
    super.key,
    required this.nextText,
    this.onNextPressed,
    this.isNextLoading = false,
    this.isNextEnabled = true,
    this.backText = 'Back',
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IosButton(
              text: nextText,
              onPressed: isNextEnabled && !isNextLoading ? onNextPressed : null,
              isLoading: isNextLoading,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBackPressed,
                child: Text(
                  backText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF007AFF),
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
