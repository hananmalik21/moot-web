import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/extensions/time_format.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/features/common_widgets/info_row.dart';

class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Information",
            style: context.text20SemiBold.copyWith(color: theme.primaryColor),
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              CircleAvatar(
                radius: 38.r,
                backgroundColor: theme.primaryColor.withOpacity(0.15),
                child: Icon(
                  Icons.person,
                  size: 42.r,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName} ${user.lastName}",
                      style: context.text22SemiBold,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Employee • Joined ${user.hireDate?.toCustomFormat() ?? '-'}",
                      style: context.text14Regular.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          InfoRowWithDivider(label: "Email", value: user.email),
          InfoRowWithDivider(label: "Phone", value: user.phoneNumber),
          InfoRowWithDivider(label: "Position", value: user.designation),
          InfoRowWithDivider(label: "Salary", value: user.salary.toString()),
          InfoRowWithDivider(label: "Status", value: user.status),
        ],
      ),
    );
  }
}
