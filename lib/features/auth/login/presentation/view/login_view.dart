import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/login/presentation/provider/login_provider.dart';
import 'package:moot_web/features/auth/login/presentation/widgets/company_info_widget.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/custom_text.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController emailController = TextEditingController(text: "admin@moot.com");
  final TextEditingController passwordController = TextEditingController(text: "Admin@123");
  final loginProvider = ChangeNotifierProvider.autoDispose<LoginProvider>(
    (ref) => LoginProvider(),
  );

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(loginProvider);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                CompanyInfoWidget(),
                Expanded(
                  child: FormContainer(
                    height: 0.49,
                    constraints: constraints,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: 'Login with:',
                          textStyle: context.text16SemiBold.copyWith(
                            color: context.gray70TextColor,
                          ),
                        ),
                        const Divider(color: Colors.white24),
                        Spacer(),

                        InputFieldWidget(
                          title: "Employee ID or Email",
                          hint: "Enter your id or email",
                          controller: emailController,
                          onChange: (val) => notifier.setButtonEnable(
                            val,
                            emailController.text,
                            passwordController.text,
                          ),
                        ),
                        20.verticalSpace,
                        InputFieldWidget(
                          title: "Password",
                          hint: "Enter password",
                          controller: passwordController,
                          obscure: true,
                          onChange: (val) => notifier.setButtonEnable(
                            val,
                            emailController.text,
                            passwordController.text,
                          ),
                        ),
                        20.verticalSpace,
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomText(
                            text: "Forgot Password?",
                            textStyle: context.text12Regular.copyWith(
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                        Spacer(),
                        customUploadBtnWidget(
                          onTap: () {
                            notifier.login(
                              password: passwordController.text,
                              email: emailController.text,
                              onSuccess: (authModel) async {
                                // authModel is AuthModel from backend
                                await ref
                                    .read(userDataProvider.notifier)
                                    .setUserData(authModel);

                                Utils().showToast("Login Successful", success: true);

                                if (mounted) {
                                  context.goNamed("dashboard");
                                }
                              },
                              onFailure: (message) =>
                                  Utils().showToast(message, success: false),
                            );
                          },


                          isLoading: notifier.loading,
                          // isEnable: notifier.isButtonEnable,
                          text: "Login",
                          context: context,
                        ),
                        // 20.verticalSpace,
                        // Column(
                        //   children: [
                        //     SizedBox(
                        //       width: double.infinity,
                        //       child: ElevatedButton(
                        //         onPressed: () {
                        //           context.go('/login');
                        //         },
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: Colors.yellow.withOpacity(
                        //             0.8,
                        //           ),
                        //           foregroundColor: Colors.black,
                        //           padding: const EdgeInsets.symmetric(
                        //             vertical: 18,
                        //           ),
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //         ),
                        //         child: const Text(
                        //           'Login',
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //         ),
                        //       ),
                        //     ),
                        //     10.verticalSpace,
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
