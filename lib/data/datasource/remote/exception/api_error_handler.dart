import 'package:dio/dio.dart';

import '../../../model/base_model/error_response.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          //print("Check Error>>>>> ${error.response!.statusCode}");

          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request to server was cancelled";
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription = "Connection timeout with server";
              break;
            case DioExceptionType.connectionError:
              errorDescription = "An error occurred";
              break;
            case DioExceptionType.unknown:
              errorDescription =
                  "Connection to server failed due to internet connection "; //${DioExceptionType.other.name}
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription = "Receive timeout in connection with server";
              break;
            case DioExceptionType.badCertificate:
              errorDescription = "Bad Certificate";
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 404:
                case 500:
                case 503:
                  errorDescription = error.response!.statusMessage;
                  break;
                case 429:
                  errorDescription = "Too many request";
                  break;
                default:
                  ErrorResponse errorResponse =
                      ErrorResponse.fromJson(error.response!.data);
                  // if (errorResponse.error != null &&
                  //     errorResponse.error. > 0)
                  if (errorResponse.error != null)
                    errorDescription = errorResponse;
                  else
                    errorDescription =
                        "Failed to load data - status code: ${error.response!.statusCode}";
              }
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = "Send timeout with server";
              break;
          }
        } else {
          errorDescription = "Unexpected error occurred";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}
