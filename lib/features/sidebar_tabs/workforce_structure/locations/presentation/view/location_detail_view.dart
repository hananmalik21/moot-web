import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/time_format.dart';

// 🧊 Glass header + Neumorphic + Dynamic Info
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/provider/locations_provider.dart';

class LocationDetailPage extends ConsumerStatefulWidget {
  const LocationDetailPage({super.key});

  @override
  ConsumerState<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends ConsumerState<LocationDetailPage> {
  final locationProvider =
      ChangeNotifierProvider.autoDispose<LocationsProvider>(
        (ref) => LocationsProvider(),
      );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("location id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Implement this in your LocationProvider
      // e.g. getLocations(locationId: id);
      ref.read(locationProvider).getLocations(locationId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locNotifier = ref.watch(locationProvider);
    final Location? location = locNotifier.selectedLocation;

    final isMobile = MediaQuery.of(context).size.width < 600;

    // Title priority: City → Country → "Location Detail"
    final String headerTitle = location?.city?.isNotEmpty == true
        ? location!.city!
        : (location?.country?.isNotEmpty == true
              ? location!.country!
              : "Location Detail");

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: locNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(context, isMobile, headerTitle, showButtons: false),

            // 👉 FLEXIBLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double fullWidth = constraints.maxWidth;
                      final double desiredWidth = fullWidth / 2 - 18.w;

                      // If very narrow, card goes full width
                      final double cardWidth = desiredWidth < 380
                          ? fullWidth
                          : desiredWidth;

                      return Wrap(
                        spacing: 22.w,
                        runSpacing: 22.h,
                        alignment: WrapAlignment.center,
                        children: [
                          // ℹ️ LOCATION INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: DynamicInfoSection(
                                title: "Location Information",
                                items: [
                                  InfoItem(
                                    label: "Street Address",
                                    value: location?.streetAddress,
                                  ),
                                  InfoItem(
                                    label: "City",
                                    value: location?.city,
                                  ),
                                  InfoItem(
                                    label: "State / Province",
                                    value: location?.stateProvince,
                                  ),
                                  InfoItem(
                                    label: "Country",
                                    value: location?.country,
                                  ),
                                  InfoItem(
                                    label: "Postal Code",
                                    value: location?.postalCode,
                                  ),
                                  InfoItem(
                                    label: "Created Date",
                                    value: location?.createdDate != null
                                        ? location!.createdDate!
                                              .toCustomFormat()
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
