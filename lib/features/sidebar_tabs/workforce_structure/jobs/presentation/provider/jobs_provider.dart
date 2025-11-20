import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/repository/jobs_repository_impl.dart';

class JobsProvider extends ChangeNotifier {
  final JobsRepositoryImpl _jobsRepositoryImpl = JobsRepositoryImpl();

  List<JobsModel> jobs = [];
  JobsModel? selectedJob;
  bool isLoading = false;

  setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  setJob(JobsModel val) {
    selectedJob = val;
    notifyListeners();
  }

  Future<void> getJobs({Function()? onSuccess,String? jobId}) async {
    setLoading(true);

    try {
      JobsResponse value = await _jobsRepositoryImpl.getJobs();

      jobs.addAll(value.data);
      if (jobId != null) {
        JobsModel? job = jobs.firstWhere(
              (element) => element.id == jobId,
        );
        setJob(job);
      }

      onSuccess != null ? onSuccess() : null;
      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${jobs.length}");
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

  Future<void> createJob({
    required Map<String, dynamic> body,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _jobsRepositoryImpl.createJob(
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${jobs.length}");
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

  Future<void> updateJob({
    required Map<String, dynamic> body,
    required String jobId,
    required Function() onSuccess,
  }) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _jobsRepositoryImpl.updateJob(
        jobId: jobId,
        body: body,
      );
      onSuccess();
      Utils().showToast("${value.message}");
      if (kDebugMode) {
        log("jobs LIST LENGTH IS ${jobs.length}");
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

  deleteJob({required String jobId}) async {
    setLoading(true);

    try {
      BaseApiResponseModel value = await _jobsRepositoryImpl.deleteJob(
        jobId: jobId,
      );

      jobs.removeWhere((element) => element.id == jobId);

      Utils().showToast("${value.message}");

      if (kDebugMode) {
        log("JOBS LIST LENGTH IS ${jobs.length}");
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
