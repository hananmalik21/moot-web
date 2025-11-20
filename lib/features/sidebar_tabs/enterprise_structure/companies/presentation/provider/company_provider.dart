import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/repository/company_repository_impl.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyRepositoryImpl _companyRepositoryImpl = CompanyRepositoryImpl();

  List<Company> companies = [];
  Company? selectedCompany;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }
  setCompany(Company? val) {
    selectedCompany = val;
    notifyListeners();
  }

  Future<void> getCompanies({String? companyId,Function()? onSuccess}) async {
    setLoading(true);

    try {
      CompaniesResponse value = await _companyRepositoryImpl.getCompanies(companyId: companyId);

      companies.addAll(value.companies);

      if (kDebugMode) {
        log("COMPANIES LIST LENGTH IS ${companies.length}");
      }
      if (companyId != null) {
        Company? manager = companies.firstWhere((element) => element.id == companyId);
        setCompany(manager);
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

  Future<void> createCompany({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _companyRepositoryImpl.createCompany(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("COMPANY LIST LENGTH IS ${companies.length}");
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

  Future<void> updateCompany({
    required Map<String, dynamic> body,
    required String companyId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _companyRepositoryImpl.updateCompany(
        companyId: companyId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("COMPANY LIST LENGTH IS ${companies.length}");
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


  deleteCompany({required String companyId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _companyRepositoryImpl.deleteCompany(
        companyId: companyId,
      );

      companies.removeWhere((element) => element.id == companyId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("COMPANY LIST LENGTH IS ${companies.length}");
        log("COMPANY LIST LENGTH IS ${companies.length}");
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
