import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl extends JobsRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<JobsResponse> getJobs() async {
    try {
      var response = await _baseService.get(url: ApiEndPoints.jobUrl);

      return JobsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteJob({required String jobId}) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.jobUrl}/$jobId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<BaseApiResponseModel> createJob({
    required Map<String,dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.jobUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateJob({
    required String jobId,
    required Map<String,dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.jobUrl}/$jobId",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
