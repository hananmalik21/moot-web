import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/features/common_widgets/info_row.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';

class DynamicInfoSection extends StatelessWidget {
  final String title;
  final bool hideTitle;
  final List<InfoItem> items; // label + value pairs

  const DynamicInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.hideTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ----------- Title -----------
            if (hideTitle==false)
              Center(
                child: Text(
                  title,
                  style: context.text20SemiBold.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            SizedBox(height: 30.h),

            /// ----------- Dynamic List -----------
            ...items.map(
              (e) => InfoRowWithDivider(label: e.label, value: e.value ?? "-"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model for each information row
class InfoItem {
  final String label;
  final String? value;

  InfoItem({required this.label, this.value});
}
