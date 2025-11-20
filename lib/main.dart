import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moot_web/core/router/app_router.dart';
import 'package:moot_web/core/utils/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to detect screen width and adapt design size
    return LayoutBuilder(
      builder: (context, constraints) {
        Size designSize;

        // You can tweak these breakpoints
        if (constraints.maxWidth >= 1920) {
          designSize = const Size(1920, 1080); // large screens
        } else if (constraints.maxWidth >= 1440) {
          designSize = const Size(1440, 1024); // typical desktop
        } else if (constraints.maxWidth >= 1024) {
          designSize = const Size(1024, 768); // small laptops/tablets
        } else {
          designSize = const Size(768, 1024); // fallback (portrait/tablet)
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return MaterialApp.router(
              title: 'Moot Web',
              theme: ThemeType().lightTheme,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
