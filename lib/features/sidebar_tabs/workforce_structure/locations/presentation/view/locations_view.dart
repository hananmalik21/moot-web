import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';
import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

// ✅ for PermissionGuard + current user's permissions
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/provider/locations_provider.dart';


class LocationsView extends ConsumerStatefulWidget {
  const LocationsView({super.key});

  @override
  ConsumerState<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends ConsumerState<LocationsView> {
  final locationsProvider =
  ChangeNotifierProvider.autoDispose<LocationsProvider>(
        (ref) => LocationsProvider(),
  );

  late final PermissionGuard _guard;

  // ── Permission getters (security.location.* and security.*) ────────────────
  bool get _canCreateLocation =>
      _guard.allows('workforce_structure.location.create') ||
          _guard.allows('workforce_structure.location.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canUpdateLocation =>
      _guard.allows('workforce_structure.location.update') ||
          _guard.allows('workforce_structure.location.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canDeleteLocation =>
      _guard.allows('workforce_structure.location.delete') ||
          _guard.allows('workforce_structure.location.*') ||
          _guard.allows('workforce_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationsProvider).getLocations();

      // Build guard from current user’s permissions
      final perms =
      (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
          .toList();
      _guard = PermissionGuard(perms);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(locationsProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;


    final hasActions = _canUpdateLocation || _canDeleteLocation;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Locations"),
              20.verticalSpace,

              // Create button only if allowed
              if (_canCreateLocation)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-location"),
                  title: "Add location",
                ),

              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: CustomDataTable(
                    emptyMessage: 'No location found',
                    headerColor: Color(0xFFc32033),
                    onRowTap: (index){
                      context.goNamed(
                        'location-detail',
                        pathParameters: {"id": notifier.locations[index].id},
                        extra: {"location": notifier.locations[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('City')),
                      const DataColumn(label: Text('Province')),
                      const DataColumn(label: Text('Street')),
                      const DataColumn(label: Text('Country')),
                      const DataColumn(label: Text('Postal Code')),
                      const DataColumn(label: Text('Creation Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      notifier.locations.length,
                          (index) {
                        final location = notifier.locations[index];
                        final isEven = index.isEven;

                        final cells = <DataCell>[
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(location.city ?? "")),
                          DataCell(Text(location.stateProvince ?? "")),
                          DataCell(Text(location.streetAddress ?? "")),
                          DataCell(Text(location.country ?? "")),
                          DataCell(Text(location.postalCode ?? "")),
                          DataCell(
                            Text(
                              location.createdDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                  .format(location.createdDate!)
                                  : '—',
                            ),
                          ),
                        ];

                        if (hasActions) {
                          cells.add(
                            DataCell(
                              Row(
                                children: [
                                  if (_canUpdateLocation)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      tooltip: 'Edit',
                                      onPressed: () {
                                        context.goNamed(
                                          'edit-location',
                                          pathParameters: {"id": location.id},
                                          extra: {"location": location},
                                        );
                                      },
                                    ),
                                  if (_canDeleteLocation)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        Utils().showCustomDialog(
                                          context,
                                          DeleteDialogWidget(
                                            onClick: () => ref
                                                .read(locationsProvider)
                                                .deleteLocation(
                                              locationId: location.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        }

                        return DataRow(
                          color: WidgetStateProperty.all(
                            isEven
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                          ),
                          cells: cells,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
