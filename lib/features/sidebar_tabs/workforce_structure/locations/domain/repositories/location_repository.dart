import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';

abstract class LocationsRepository {
  Future<BaseApiResponseModel> createLocation({
    required Map<String, dynamic> body,
  });

  Future<LocationsResponse> getLocations();

  Future<BaseApiResponseModel> deleteLocation({required String locationId});

  Future<BaseApiResponseModel> updateLocation({required String locationId,    required Map<String, dynamic> body,
  });
}
