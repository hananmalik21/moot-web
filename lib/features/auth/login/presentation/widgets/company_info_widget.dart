import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyInfoWidget extends StatelessWidget {
  const CompanyInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Superlist',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Revolutionize your business documents',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 30.sp,
              ),
            ),
            40.verticalSpace,
            const _LeftFeature(
              icon: Icons.people_outline,
              title: 'Invite unlimited colleagues',
              desc:
                  'Integrate with developer-friendly APIs or build low-code solutions.',
            ),
            20.verticalSpace,
            const _LeftFeature(
              icon: Icons.verified_user_outlined,
              title: 'Ensure compliance',
              desc:
                  'Get real-time insights on all your data and visitor sources.',
            ),
            20.verticalSpace,
            const _LeftFeature(
              icon: Icons.security_outlined,
              title: 'Built-in security',
              desc: 'Keep your team members safe by sharing secure dashboards.',
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _LeftFeature({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
