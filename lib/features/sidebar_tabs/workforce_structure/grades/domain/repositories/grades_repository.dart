import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';

abstract class GradesRepository {
  Future<BaseApiResponseModel> createGrade({
    required Map<String, dynamic> body,
  });

  Future<GradeResponse> getGrades();

  Future<BaseApiResponseModel> deleteGrade({required String gradeId});

  Future<BaseApiResponseModel> updateGrade({
    required String gradeId,
    required Map<String, dynamic> body,
  });
}
