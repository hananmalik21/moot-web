import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/repository/location_repository_impl.dart';

class LocationsProvider extends ChangeNotifier {
  final LocationRepositoryImpl _locationsRepositoryImpl = LocationRepositoryImpl();

  List<Location> locations = [];
  Location? selectedLocation;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setLocation(Location val) {
    selectedLocation = val;
    log("loction is ${selectedLocation?.id}");
    notifyListeners();
  }

  Future<void> getLocations({String? locationId,Function()? onSuccess}) async {
    setLoading(true);

    try {
      LocationsResponse value = await _locationsRepositoryImpl.getLocations();

      locations.addAll(value.locations);
      if (locationId != null) {
        Location? location = locations.firstWhere((element) => element.id == locationId);
        setLocation(location);
        onSuccess != null ? onSuccess() : null;
      }

      if (kDebugMode) {
        log("LOCATIONS LIST LENGTH IS ${locations.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }



  Future<void> createLocation({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _locationsRepositoryImpl.createLocation(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${locations.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> updateLocation({
    required Map<String, dynamic> body,
    required String locationId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _locationsRepositoryImpl.updateLocation(
        locationId: locationId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${locations.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  deleteLocation({required String locationId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _locationsRepositoryImpl.deleteLocation(
        locationId: locationId,
      );

      locations.removeWhere((element) => element.id == locationId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${locations.length}");
      }
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }
}
