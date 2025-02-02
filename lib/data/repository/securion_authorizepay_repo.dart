import 'package:dio/dio.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasource/remote/dio/dio_client.dart';
import '../datasource/remote/exception/api_error_handler.dart';
import '../model/base_model/api_response.dart';

class SecurionPayAuthorizenetRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  SecurionPayAuthorizenetRepo(
      {required this.dioClient, required this.sharedPreferences});

  Future<ApiResponse> cardPaymentRequest(
      dynamic trxId,
      dynamic amount,
      dynamic gateway,
      dynamic cardNumber,
      dynamic cardName,
      dynamic expiryMonth,
      dynamic expiryYear,
      dynamic cardCVC) async {
    try {
      print("trx_id: $trxId");
      print("amount: $amount");
      print("gateway: $gateway");
      print("card_number: $cardNumber");
      print("card_name: $cardName");
      print("expiry_month: $expiryMonth");
      print("expiry_year: $expiryYear");
      print("card_cvc: $cardCVC");
      Response response = await dioClient.post(
        AppConstants.cardPayments,
        queryParameters: {
          "amount": amount,
          "gateway": gateway,
          "card_number": cardNumber,
          "card_name": cardName,
          "expiry_month": expiryMonth,
          "expiry_year": expiryYear,
          "card_cvc": cardCVC,
          "trx_id": trxId,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("card payment ---------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
