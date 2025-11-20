import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:moot_web/features/common_widgets/background_widget.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';

class SignupPage extends ConsumerWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (_, constraints) {
          return BackgroundWidget(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT SECTION
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Superlist',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w600,
                                fontSize: 24.sp,
                              ),
                            ),
                            24.verticalSpace,
                            Text(
                              'Revolutionize your business documents',
                              style: TextStyle(
                                color: Colors.yellow,
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
                              desc:
                                  'Keep your team members safe by sharing secure dashboards.',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // RIGHT FORM
                    Expanded(
                      child: FormContainer(
                        constraints: constraints,
                        child: Column(
                          children: [
                            // scrollable input section
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Register with:',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Full Name",
                                      hint: "Enter your name",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Email",
                                      hint: "Enter your email",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Role",
                                      hint: "Enter your role",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Mobile Number",
                                      hint: "Enter your mobile no",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Department ID",
                                      hint: "Enter your department id",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Designation",
                                      hint: "Enter your designation",
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Employee ID",
                                      hint: "Enter your employees id",
                                    ),
                                    20.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InputFieldWidget(
                                            title: "Password",
                                            hint: "Password",
                                          ),
                                        ),
                                        10.horizontalSpace,
                                        Expanded(
                                          child: InputFieldWidget(
                                            title: "Confirm Password",
                                            hint: "Confirm Password",
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                  ],
                                ),
                              ),
                            ),

                            // static footer
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.goNamed('/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow
                                          .withOpacity(0.8),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                10.verticalSpace,
                                const Text(
                                  'By creating an account, you agree to the Terms of Service.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                20.verticalSpace,
                                const Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: Colors.yellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FormContainer extends StatelessWidget {
  const FormContainer({
    super.key,
    required this.child,
    required this.constraints,
    this.height = 0.75,
    this.width = 0.6,
  });

  final Widget child;
  final BoxConstraints constraints;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width?.sw,
        padding: const EdgeInsets.all(32),

        // ⭐ CLEANER NEUMORPHIC STYLE
        decoration: BoxDecoration(
          color: Colors.white, // pure, clean
          borderRadius: BorderRadius.circular(18),

          // Slight crisp rim
          border: Border.all(
            color: Colors.white.withOpacity(0.9),
            width: 1,
          ),

          boxShadow: [
            // ⭐ Sharper top-left highlight (more clarity)
            BoxShadow(
              color: Colors.white.withOpacity(1.0),
              offset: const Offset(-5, -5),
              blurRadius: 10,
            ),

            // ⭐ Sharper bottom-right shadow (clearer look)
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),

            // ⭐ Very soft ambient depth (adds clarity, not heaviness)
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),

        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight * height,
        ),

        child: child,
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
        Icon(icon, color: Colors.yellow, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
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
