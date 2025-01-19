import 'package:dio/dio.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasource/remote/dio/dio_client.dart';
import '../datasource/remote/exception/api_error_handler.dart';
import '../model/base_model/api_response.dart';

class PaymentDoneRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  PaymentDoneRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponse> paymentDoneRequest(
    dynamic trxId,
    dynamic gateway,
    dynamic amount,
  ) async {
    try {
      Response response = await dioClient.post(
        "${AppConstants.paymentDoneUri}$trxId",
        queryParameters: {
          "gateway": gateway,
          "amount": amount,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
