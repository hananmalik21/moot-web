import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart'
    show BaseApiResponseModel;
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/data/model/position_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/repository/position_repository_impl.dart';

class PositionProvider extends ChangeNotifier {
  final PositionRepositoryImpl _positionRepositoryImpl =
      PositionRepositoryImpl();

  List<Position> positions = [];
  bool isLoading = false;

  JobsModel? selectedJob;
  Position? selectedPosition;
  Department? selectedDepartment;
  Grade? selectedGrade;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setPosition(Position? val) {
    selectedPosition = val;
    notifyListeners();
  }

  void setJob(JobsModel? val, {List<JobsModel> jobs = const []}) {
    if (val == null) return; // early return if val is null

    if (jobs.isNotEmpty) {
      final newJob = jobs.firstWhere(
        (element) => element.id == val.id,
        orElse: () => val,
      );

      selectedJob = newJob;
      notifyListeners();
      return;
    }

    selectedJob = val;
    notifyListeners();
  }

  void setDepartment(
    Department? val, {
    List<Department> departments = const [],
  }) {
    if (val == null) return; // early return if val is null

    if (departments.isNotEmpty) {
      final newDepartment = departments.firstWhere(
        (element) => element.id == val.id,
        orElse: () => val,
      );
      selectedDepartment = newDepartment;
      notifyListeners();
      return;
    }
    selectedDepartment = val;
    notifyListeners();
  }

  void setGrade(Grade? val, {List<Grade> grades = const []}) {
    if (val == null) return; // early return if val is null

    if (grades.isNotEmpty) {
      final newGrade = grades.firstWhere(
        (element) => element.id == val.id,
        orElse: () => val,
      );
      selectedGrade = newGrade;
      notifyListeners();
      return;
    }
    selectedGrade = val;
    notifyListeners();
  }

  void clearList(){
    positions.clear();
    notifyListeners();
  }

  Future<void> getPositions({
    Function()? onSuccess,
    String? positionId,
    String? departmentId,
  }) async {
    setLoading(true);

    debugPrint("position is $departmentId");
    try {
      PositionResponse value = await _positionRepositoryImpl.getPositions(
        departmentId: departmentId,
        positionId: positionId,
      );
      if (departmentId != null) {
        positions.clear();
        selectedPosition = null;
      }
      positions.addAll(value.positions);

      if (kDebugMode) {
        log("GRADES LIST LENGTH IS ${positions.length}");
      }
      if (positionId != null) {
        debugPrint("position id is $positionId");
        Position? position = positions.firstWhere(
          (element) => element.id == positionId,
        );
        setPosition(position);
      }
      onSuccess != null ? onSuccess() : null;
    } catch (err) {
      if (kDebugMode) {
        log("ERROR IS ${err.toString()}");
      }
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> createPosition({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _positionRepositoryImpl.createPosition(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${positions.length}");
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

  Future<void> updatePosition({
    required Map<String, dynamic> body,
    required String jobId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _positionRepositoryImpl.updatePosition(
        positionId: jobId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${positions.length}");
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

  deletePosition({required String positionId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _positionRepositoryImpl.deletePosition(
        positionId: positionId,
      );

      positions.removeWhere((element) => element.id == positionId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("positions LIST LENGTH IS ${positions.length}");
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
