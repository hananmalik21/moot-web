import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/data/model/position_model.dart';

abstract class PositionsRepository {
  Future<BaseApiResponseModel> createPosition({
    required Map<String, dynamic> body,
  });

  Future<PositionResponse> getPositions({String? departmentId,String? positionId});

  Future<BaseApiResponseModel> deletePosition({required String positionId});

  Future<BaseApiResponseModel> updatePosition({
    required String positionId,
    required Map<String, dynamic> body,
  });
}
