import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/repository/grades_repository_impl.dart';

class GradeProvider extends ChangeNotifier {
  final GradesRepositoryImpl _gradesRepositoryImpl = GradesRepositoryImpl();

  List<Grade> grades = [];
  Grade? selectedGrade;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setGrade(Grade val) {
    selectedGrade = val;
    debugPrint("SeLECTED GRADE IS ${selectedGrade?.gradeName}");
    notifyListeners();
  }

  Future<void> getGrades({Function()? onSuccess,String? gradeId}) async {
    setLoading(true);

    try {
      GradeResponse value = await _gradesRepositoryImpl.getGrades();

      grades.addAll(value.grades);

      if (kDebugMode) {
        log("GRADES LIST LENGTH IS ${grades.length}");
      }
      if (gradeId != null) {
        debugPrint("grade id is $gradeId");

        Grade? grade = grades.firstWhere(
              (element) => element.id == gradeId,
        );
        setGrade(grade);
      }
      onSuccess != null ? onSuccess() : null;
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

  Future<void> createGrade({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _gradesRepositoryImpl.createGrade(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${grades.length}");
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

  Future<void> updateGrade({
    required Map<String, dynamic> body,
    required String gradeId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _gradesRepositoryImpl.updateGrade(
        gradeId: gradeId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${grades.length}");
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


  deleteGrade({required String gradeId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _gradesRepositoryImpl.deleteGrade(
        gradeId: gradeId,
      );

      grades.removeWhere((element) => element.id == gradeId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${grades.length}");
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
