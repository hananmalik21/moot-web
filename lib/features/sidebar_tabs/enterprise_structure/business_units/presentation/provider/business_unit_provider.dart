import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/repository/business_unit_repository_impl.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';

class BusinessUnitProvider extends ChangeNotifier {
  final BusinessUnitsRepositoryImpl _businessUnitsRepositoryImpl =
      BusinessUnitsRepositoryImpl();

  List<BusinessUnit> businessUnits = [];
  Company? selectedCompany;
  BusinessUnit? selectedBusinessUnit;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void setCompany(Company? val, {List<Company> companies = const []}) {
    if (val == null) return; // early return if val is null

    if (companies.isNotEmpty) {
      final newCompany = companies.firstWhere(
        (element) => element.id == val.id,
        orElse: () => val,
      );

      selectedCompany = newCompany;
      notifyListeners();
      return;
    }

    selectedCompany = val;
    notifyListeners();
  }

  void setBusinessUnit(
    BusinessUnit? val, {
    List<BusinessUnit> businessUnits = const [],
  }) {
    if (val == null) return; // early return if val is null

    if (businessUnits.isNotEmpty) {
      final newUnit = businessUnits.firstWhere(
        (element) => element.id == val.id,
        orElse: () => val,
      );

      selectedBusinessUnit = newUnit;
      notifyListeners();
      return;
    }

    selectedBusinessUnit = val;
    notifyListeners();
  }

  Future<void> getBusinessUnits({
    String? businessUnitId,
    Function()? onSuccess,
    String? companyId,
  }) async {
    setLoading(true);

    try {
      BusinessUnitsResponse value = await _businessUnitsRepositoryImpl
          .getBusinessUnits(companyId: companyId,businessUnitId: businessUnitId);
      if (companyId != null) {
        businessUnits.clear();

        log("list is ${businessUnits.length}");
        selectedBusinessUnit = null;
        notifyListeners();
      }

      businessUnits.addAll(value.businessUnits);
      if (businessUnitId != null) {
        BusinessUnit? manager = businessUnits.firstWhere(
          (element) => element.id == businessUnitId,
        );
        setBusinessUnit(manager);
      }

      if (kDebugMode) {
        log("Business units LIST LENGTH IS ${businessUnits.length}");
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

  Future<void> createBusinessUnit({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _businessUnitsRepositoryImpl
          .createBusinessUnit(body: body);
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("Business units LIST LENGTH IS ${businessUnits.length}");
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

  Future<void> updateBusinessUnit({
    required Map<String, dynamic> body,
    required String businessUnitId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _businessUnitsRepositoryImpl
          .updateBusinessUnit(businessUnitId: businessUnitId, body: body);
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("Business units  LIST LENGTH IS ${businessUnits.length}");
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

  deleteBusinessUnit({required String businessUnitId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _businessUnitsRepositoryImpl
          .deleteBusinessUnit(businessUnitId: businessUnitId);

      businessUnits.removeWhere((element) => element.id == businessUnitId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("Business units  LIST LENGTH IS ${businessUnits.length}");
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
