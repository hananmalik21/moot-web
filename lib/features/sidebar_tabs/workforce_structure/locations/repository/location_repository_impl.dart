import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/domain/repositories/location_repository.dart';

class LocationRepositoryImpl extends LocationsRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<LocationsResponse> getLocations() async {
    try {
      var response = await _baseService.get(url: ApiEndPoints.locationsUrl);

      return LocationsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteLocation({
    required String locationId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.locationsUrl}/$locationId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createLocation({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.locationsUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateLocation({
    required String locationId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.locationsUrl}/$locationId",
        body: body,
      );
      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
