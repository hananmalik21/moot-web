import 'package:flutter/widgets.dart';
import 'package:moot_web/core/extensions/colors.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 12),
      color: context.blackColor.withAlpha(20),
    );
  }
}
