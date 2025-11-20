import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/domain/repositories/grades_repository.dart';

class GradesRepositoryImpl extends GradesRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<GradeResponse> getGrades() async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.gradesUrl,
      );

      return GradeResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteGrade({required String gradeId}) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.gradesUrl}/$gradeId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createGrade({
    required Map<String,dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.gradesUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<BaseApiResponseModel> updateGrade({
    required String gradeId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.gradesUrl}/$gradeId",
        body: body
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
