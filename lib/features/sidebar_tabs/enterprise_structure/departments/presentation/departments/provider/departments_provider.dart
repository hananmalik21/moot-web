import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/repository/departments_repository_impl.dart';

class DepartmentsProvider extends ChangeNotifier {
  // Repository
  final DepartmentsRepositoryImpl _repo = DepartmentsRepositoryImpl();

  // State
  List<Department> departments = [];
  bool isLoading = false;
  Department? selectedDepartment;

  // --------- Internal helpers ---------
  void setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void setDepartment(Department? val) {
    selectedDepartment = val;
    notifyListeners();
  }

  void clearList(){
    departments.clear();
    notifyListeners();
  }

  void _log(String message) {
    if (kDebugMode) log(message);
  }

  // --------- Actions ---------

  Future<void> createDepartment({
    required String departmentName,
    required String companyId,
    required String businessUnitId,
    required String managerId,
    required String locationId,
    required Function() onSuccess,
  }) async {
    setLoading(true);
    try {
      final BaseApiResponseModel value = await _repo.createDepartment(
        body: {
          'departmentName': departmentName,
          'location': locationId,
          'manager': managerId,
          'company': companyId,
          'businessUnit': businessUnitId,
        },
      );

      onSuccess();
      Utils().showToast('${value.message}');
      _log('departments LIST LENGTH IS ${departments.length}');
    } catch (err) {
      _log('ERROR IS ${err.toString()}');
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> updateDepartment({
    required String departmentName,
    required String companyId,
    required String businessUnitId,
    required String departmentId,
    required String managerId,
    required String locationId,
    required Function() onSuccess,
  }) async {
    setLoading(true);
    try {
      final BaseApiResponseModel value = await _repo.updateDepartment(
        departmentId: departmentId,
        body: {
          'departmentName': departmentName,
          'location': locationId,
          'manager': managerId,
          'company': companyId,
          'businessUnit': businessUnitId,
        },
      );

      onSuccess();
      Utils().showToast('${value.message}');
      _log('departments LIST LENGTH IS ${departments.length}');
    } catch (err) {
      _log('ERROR IS ${err.toString()}');
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> getDepartments({
    String? departmentId,
    String? businessUnitId,
    Function()? onSuccess,
  }) async {
    setLoading(true);
    try {
      final DepartmentsModel value = await _repo.getDepartments(businessUnitId: businessUnitId,);
      if (businessUnitId != null) {
        departments.clear();
        selectedDepartment = null;
        notifyListeners();
      }


      // Preserve original behavior: add to existing list (no clear)
      departments.addAll(value.data);
      if (departmentId != null) {
        Department? dept = departments.firstWhere(
              (element) => element.id == departmentId,
        );
        setDepartment(dept);
      }

      onSuccess?.call();

      if (departmentId != null) {
        final Department dept =
        departments.firstWhere((e) => e.id == departmentId);
        setDepartment(dept);
        onSuccess?.call();
      }

      _log('ORDERS LIST LENGTH IS ${departments.length}');
    } catch (err) {
      _log('ERROR IS ${err.toString()}');
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> deleteDepartment({required String departmentId}) async {
    setLoading(true);
    try {
      final BaseApiResponseModel value =
      await _repo.deleteDepartment(departmentId: departmentId);

      departments.removeWhere((e) => e.id == departmentId);

      Utils().showToast('${value.message}');
      _log('departments LIST LENGTH IS ${departments.length}');
    } catch (err) {
      _log('ERROR IS ${err.toString()}');
      Utils().showToast(err.toString(), success: false);
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }
}
