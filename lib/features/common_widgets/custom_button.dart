import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'custom_text.dart';
Widget customUploadBtnWidget({
  icon,
  required String text,
  double? width,
  VoidCallback? onTap,
  bool isLoading = false,
  bool isAnimated = false,
  bool isEnable = true,
  required BuildContext context,
  Color? loaderColor,
  Color? buttonColor,
  TextStyle? textStyle,
  Color borderColor = Colors.transparent,
  Color? textColor,
  double height = 50,
  double? fontSize,
  double borderRadius = 6,
  double loaderSize = 15,
}) {
  final ValueNotifier<bool> isHovered = ValueNotifier(false);

  return ValueListenableBuilder<bool>(
    valueListenable: isHovered,
    builder: (context, hovered, _) {
      final effectiveColor = isEnable
          ? (buttonColor ?? context.primaryColor)
          : const Color(0xFFB8860B); // Dark Yellow when disabled

      Widget child = AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(5),
        height: height.h,
        width: width?.w ?? double.infinity,
        decoration: BoxDecoration(
          color: isEnable && hovered
              ? effectiveColor.withOpacity(0.85)
              : effectiveColor,
          borderRadius: BorderRadius.circular(isAnimated ? 25 : borderRadius),
          border: Border.all(color: borderColor),
          boxShadow: isEnable && hovered
              ? [
            BoxShadow(
              color: effectiveColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: isLoading
            ? Center(
          child: SizedBox(
            height: loaderSize,
            width: loaderSize,
            child: CupertinoActivityIndicator(
              color: loaderColor ?? Colors.white,
              animating: true,
            ),
          ),
        )
            : Center(
          child: CustomText(
            text: text,
            maxLines: 2,
            textStyle: textStyle ??
                context.text14Medium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEnable
                      ? textColor ?? context.textFieldColor
                      : Colors.black54,
                ),
          ),
        ),
      );

      // Wrap with GestureDetector only if enabled and not loading
      if (isEnable && !isLoading && onTap != null) {
        child = GestureDetector(
          onTap: onTap,
          child: child,
        );
      }

      return MouseRegion(
        onEnter: isEnable ? (_) => isHovered.value = true : null,
        onExit: isEnable ? (_) => isHovered.value = false : null,
        cursor: isEnable && !isLoading
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: child,
      );
    },
  );
}


// Widget customUploadBtnWidget({
//   icon,
//   required String text,
//   double? width,
//   onTap,
//   bool isLoading = false,
//   bool isAnimated = false,
//   bool isEnable = true,
//   required BuildContext context,
//   Color? loaderColor,
//   Color? buttonColor,
//   TextStyle? textStyle,
//   Color borderColor = Colors.transparent,
//   Color? textColor,
//   double height = 50,
//   double? fontSize,
//   double borderRadius = 6,
//   double loaderSize = 15,
// }) {
//   final ValueNotifier<bool> isHovered = ValueNotifier(false);
//
//   return ValueListenableBuilder<bool>(
//     valueListenable: isHovered,
//     builder: (context, hovered, _) {
//       final effectiveColor = isEnable
//           ? (buttonColor ?? context.primaryColor)
//           : Theme.of(context).colorScheme.tertiary;
//
//       return MouseRegion(
//         onEnter: (_) => isHovered.value = true,
//         onExit: (_) => isHovered.value = false,
//         cursor: isEnable && !isLoading
//             ? SystemMouseCursors.click
//             : SystemMouseCursors.basic,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.all(5),
//           height: height,
//           width: width ?? double.infinity,
//           decoration: BoxDecoration(
//             color: hovered
//                 ? effectiveColor.withOpacity(0.85) // 👈 hover effect
//                 : effectiveColor,
//             borderRadius: BorderRadius.circular(isAnimated ? 25 : borderRadius),
//             border: Border.all(color: borderColor),
//             boxShadow: hovered
//                 ? [
//                     BoxShadow(
//                       color: effectiveColor.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: isLoading
//               ? Center(
//                   child: SizedBox(
//                     height: loaderSize,
//                     width: loaderSize,
//                     child: CupertinoActivityIndicator(
//                       color: loaderColor ?? ThemeType.whiteColor,
//                       animating: true,
//                     ),
//                   ),
//                 )
//               : Center(
//                   child: CustomText(
//                     text: text,
//                     maxLines: 2,
//                     textStyle:
//                         textStyle ??
//                         context.text14Medium.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isEnable
//                               ? textColor ?? ThemeType.blackColor
//                               : Theme.of(context).colorScheme.onTertiary,
//                         ),
//                   ),
//                 ),
//         ),
//       );
//     },
//   );
// }

// Widget customUploadBtnWidget({
//   icon,
//   required String text,
//   double? width,
//   onTap,
//   bool isLoading = false,
//   bool isAnimated = false,
//   bool isEnable = true,
//   required BuildContext context,
//   Color? loaderColor,
//   Color? buttonColor,
//   TextStyle? textStyle,
//   Color borderColor = Colors.transparent,
//   Color? textColor,
//   double height = 50,
//   double? fontSize,
//   double borderRadius = 6,
//   double loaderSize = 15,
// }) {
//   return GestureDetector(
//     onTap: isEnable && !isLoading ? onTap : null,
//     child: Container(
//       padding: const EdgeInsets.all(5),
//       height: height,
//       width: width ?? double.infinity,
//       decoration: BoxDecoration(
//         color: isEnable?buttonColor??context.primaryColor:Theme.of(context).colorScheme.tertiary,
//         borderRadius: BorderRadius.circular(
//           isAnimated ? 25 : borderRadius,
//         ),
//         border: Border.all(
//           color: borderColor,
//         ),
//       ),
//       child: isLoading
//           ? Center(
//               child: SizedBox(
//                 height: loaderSize,
//                 width: loaderSize,
//                 child: CircularProgressIndicator(
//                   color: ThemeType.whiteColor,
//                   strokeWidth: 2,
//                 ),
//               ),
//             )
//           : Center(
//               child: CustomText(
//                 text: text,
//                 maxLines: 2,
//                 textStyle: textStyle??context.text14Medium.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: isEnable?textColor??ThemeType.blackColor:Theme.of(context).colorScheme.onTertiary,
//                       // isEnable
//                       //     ? textColor ?? ThemeType.primaryColor
//                       //     : textColor?.withOpacity(0.4) ??
//                       //         Theme.of(context).colorScheme.onTertiary,
//                     ),
//               ),
//             ),
//     ),
//   );
// }
