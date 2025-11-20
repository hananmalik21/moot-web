import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';

abstract class JobsRepository {
  Future<BaseApiResponseModel> createJob({required Map<String, dynamic> body});

  Future<JobsResponse> getJobs();

  Future<BaseApiResponseModel> deleteJob({required String jobId});

  Future<BaseApiResponseModel> updateJob({
    required String jobId,
    required Map<String, dynamic> body,
  });
}
