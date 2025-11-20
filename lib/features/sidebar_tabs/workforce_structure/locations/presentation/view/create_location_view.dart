import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/provider/locations_provider.dart';

class CreateLocationView extends ConsumerStatefulWidget {
  const CreateLocationView({super.key});

  @override
  ConsumerState<CreateLocationView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<CreateLocationView> {
  bool isEdit = false;
  Location? location;
  final TextEditingController streetAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  final locationProvider =
      ChangeNotifierProvider.autoDispose<LocationsProvider>(
        (ref) => LocationsProvider(),
      );

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    final dept = extra?['location'] as Location?;
    location = dept;
    isEdit = location != null;

    streetAddressController.text = location?.streetAddress ?? "";
    cityController.text = location?.city ?? "";
    provinceController.text = location?.stateProvince ?? "";
    countryController.text = location?.country ?? "";
    postalCodeController.text = location?.postalCode ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final locationNotifier = ref.watch(locationProvider);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: locationNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FormContainer(
                        constraints: constraints,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      isEdit
                                          ? 'Edit Location'
                                          : 'Create Location',
                                      style: context.text20SemiBold
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Street Address",
                                      hint: "Enter address",
                                      controller: streetAddressController,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "City",
                                      hint: "Enter city",
                                      controller: cityController,
                                      minLines: 4,
                                      maxLines: 8,
                                      showPadding: true,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "State Province",
                                      hint: "Enter province",
                                      controller: provinceController,
                                    ),

                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Country",
                                      hint: "Enter country",
                                      controller: countryController,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Postal Code",
                                      hint: "Enter postal code",
                                      controller: postalCodeController,
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
                                  child: customUploadBtnWidget(
                                    isLoading: locationNotifier.isLoading,
                                    onTap: () {
                                      final body = {
                                        "streetAddress":
                                            streetAddressController.text,
                                        "city": cityController.text,
                                        "stateProvince":
                                            provinceController.text,
                                        "country": countryController.text,
                                        "postalCode":
                                            postalCodeController.text,
                                      };
                                      if (isEdit) {
                                        locationNotifier.updateLocation(
                                          locationId: location?.id ?? "",

                                          body: body,
                                          onSuccess: () {
                                            context.goNamed('locations');
                                          },
                                        );
                                        return;
                                      }
                                      locationNotifier.createLocation(
                                        body: body,
                                        onSuccess: () {
                                          context.goNamed('locations');
                                        },
                                      );
                                    },
                                    text: isEdit ? "Edit" : "Create",
                                    context: context,
                                  ),
                                ),
                                20.verticalSpace,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
