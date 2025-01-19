import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasource/remote/dio/dio_client.dart';
import '../datasource/remote/exception/api_error_handler.dart';
import '../model/base_model/api_response.dart';

class PayoutRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  PayoutRepo({required this.dioClient, required this.sharedPreferences});

  ///Get Payout Data
  Future<ApiResponse> getPayoutData() async {
    try {
      Response response = await dioClient.get(
        "${AppConstants.payoutUri}",
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

  ///Get Bank Payout Form Data
  Future<ApiResponse> getPayoutBankFormData(dynamic bankName) async {
    try {
      Response response = await dioClient.post(
        "${AppConstants.getPayoutBankFormUri}",
        data: {"bankName": bankName},
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

  ///Get Bank PayStack Dropdown Data
  Future<ApiResponse> getPayStackDropDownData(dynamic currencyCode) async {
    try {
      Response response = await dioClient.post(
        "${AppConstants.getPayoutBankPayStackUri}",
        data: {"currencyCode": currencyCode},
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

  Response? response;

  Future<ApiResponse> payoutRequest(dynamic walletType, dynamic amount,
      dynamic gatewayId, dynamic supportedCurrency) async {
    print("wallet_type: $walletType");
    print("amount: $amount");
    print("gatewayId: $gatewayId");
    print("supportedCurrency: $supportedCurrency");
    try {
      Response response = await dioClient.post(
        AppConstants.payoutRequestUri,
        queryParameters: {
          "wallet_type": walletType,
          "amount": amount,
          "payout_method_id": gatewayId,
          "supported_currency": supportedCurrency,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("payout request: ------------------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// PayoutRequest
  // Future<ApiResponse> payoutConfirm(
  //   dynamic walletType,
  //   dynamic gateway,
  //   dynamic amount,
  //   List<dynamic> fieldNames,
  //   List<dynamic> fieldValues, {
  //   dynamic currencyCode,
  //   dynamic recipientType,
  //   dynamic selectBank,
  // }) async {
  //   try {
  //     dio.FormData formData = dio.FormData(); // Create FormData for file uploads

  //     formData.fields.add(MapEntry("wallet_type", walletType.toString()));
  //     formData.fields.add(MapEntry("gateway", gateway.toString()));
  //     formData.fields.add(MapEntry("amount", amount.toString()));
  //     formData.fields.add(MapEntry("currency_code", currencyCode.toString()));
  //     formData.fields.add(MapEntry("recipient_type", recipientType.toString()));
  //     formData.fields.add(MapEntry("select_bank", selectBank.toString()));

  //     for (int i = 0; i < fieldNames.length; i++) {
  //       String fieldName = fieldNames[i];
  //       dynamic fieldValue = fieldValues[i];

  //       if (fieldValue is dio.MultipartFile) {
  //         // If the fieldValue is already a MultipartFile, add it as is
  //         formData.files.add(
  //           MapEntry(fieldName, fieldValue),
  //         );
  //       } else if (fieldValue is File) {
  //         // If the fieldValue is a File, create a MultipartFile from it and add it
  //         formData.files.add(
  //           MapEntry(
  //             fieldName,
  //             await dio.MultipartFile.fromFile(fieldValue.path),
  //           ),
  //         );
  //       } else if (fieldValue is String && _isImageFile(fieldValue)) {
  //         // If the fieldValue is a String and it represents an image file path, add it as a MultipartFile
  //         formData.files.add(
  //           MapEntry(
  //             fieldName,
  //             await dio.MultipartFile.fromFile(fieldValue),
  //           ),
  //         );
  //       } else {
  //         // If it's not an image file or MultipartFile, add it as a regular field
  //         formData.fields.add(
  //           MapEntry(fieldName, fieldValue.toString()),
  //         );
  //       }
  //     }

  //     Response response = await dioClient.post(
  //       AppConstants.payoutConfirmUri,
  //       data: formData,
  //       options: Options(headers: {
  //         'Content-Type': 'multipart/form-data',
  //         "Authorization": "Bearer ${sharedPreferences.getString(AppConstants.token)}",
  //       }),
  //     );

  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }

  /// manualPayment
  Future<ApiResponse> payoutConfirm(
      dynamic trxId,
      Map<String, File?> pickedFiles,
      Map<String, TextEditingController> textControllers) async {
    try {
      // Add text field values to formData
      FormData formData = FormData.fromMap({
        ...textControllers.map(
            (fieldName, controller) => MapEntry(fieldName, controller.text)),
      });

      textControllers.forEach((key, value) {
        print("$key: ${value.text}");
      });

      // Add image files to formData
      for (var entry in pickedFiles.entries) {
        var fieldName = entry.key;
        var file = entry.value;
        if (file != null) {
          formData.files.add(
            MapEntry(
              fieldName,
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last),
            ),
          );
        }
      }

      Response response = await dioClient.post(
        "${AppConstants.payoutConfirmUri}/$trxId",
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("payout confirm --------------------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> flutterwavePayoutConfirm(
      dynamic trxId,
      dynamic selectedCurrencyName,
      dynamic selectedTransferName,
      dynamic selectedFlutterwaveBankName,
      Map<String, File?> pickedFiles,
      Map<String, TextEditingController> textControllers) async {
    try {
      // Add text field values to formData
      FormData formData = FormData.fromMap({
        'currency_code': selectedCurrencyName,
        'transfer_name': selectedTransferName,
        'bank': selectedFlutterwaveBankName,
        ...textControllers.map(
            (fieldName, controller) => MapEntry(fieldName, controller.text)),
      });

      textControllers.forEach((key, value) {
        print("$key: ${value.text}");
      });

      // Add image files to formData
      for (var entry in pickedFiles.entries) {
        var fieldName = entry.key;
        var file = entry.value;
        if (file != null) {
          formData.files.add(
            MapEntry(
              fieldName,
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last),
            ),
          );
        }
      }

      Response response = await dioClient.post(
        "${AppConstants.flutterWaveUri}/$trxId",
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("flutterwave payout confirm --------------------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> paystackConfirm(
      dynamic trxId,
      dynamic selectedCurrencyName,
      dynamic selectedTransferName,
      dynamic selectedPaystackBankName,
      Map<String, File?> pickedFiles,
      Map<String, TextEditingController> textControllers) async {
    try {
      // Add text field values to formData
      FormData formData = FormData.fromMap({
        'currency_code': selectedCurrencyName,
        'transfer_name': selectedTransferName,
        'bank': selectedPaystackBankName,
        ...textControllers.map(
            (fieldName, controller) => MapEntry(fieldName, controller.text)),
      });

      textControllers.forEach((key, value) {
        print("$key: ${value.text}");
      });

      // Add image files to formData
      for (var entry in pickedFiles.entries) {
        var fieldName = entry.key;
        var file = entry.value;
        if (file != null) {
          formData.files.add(
            MapEntry(
              fieldName,
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last),
            ),
          );
        }
      }

      Response response = await dioClient.post(
        "${AppConstants.paystackSubmitUri}/$trxId",
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("paystack confirm --------------------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  bool _isImageFile(String filePath) {
    // Add your logic here to determine if the filePath represents an image file.
    // You can check the file extension, MIME type, or any other method that suits your needs.
    // For simplicity, this example assumes that any string ending with ".jpg" or ".png" is an image file.
    return filePath.endsWith(".jpg") ||
        filePath.endsWith(".png") ||
        filePath.endsWith(".jpeg");
  }

  // /// FlutterWave PayoutRequest
  // Future<ApiResponse> flutterWavePayoutRequest(
  //   dynamic walletType,
  //   dynamic gateway,
  //   dynamic amount,
  //   List<dynamic> fieldNames,
  //   List<dynamic> fieldValues, {
  //   dynamic currencyCode,
  //   dynamic bank,
  //   dynamic transferName,
  // }) async {
  //   try {
  //     dio.FormData formData = dio.FormData(); // Create FormData for file uploads

  //     formData.fields.add(MapEntry("wallet_type", walletType.toString()));
  //     formData.fields.add(MapEntry("gateway", gateway.toString()));
  //     formData.fields.add(MapEntry("amount", amount.toString()));
  //     formData.fields.add(MapEntry("currency_code", currencyCode.toString()));
  //     formData.fields.add(MapEntry("transfer_name", transferName.toString()));
  //     formData.fields.add(MapEntry("bank", bank.toString()));

  //     for (int i = 0; i < fieldNames.length; i++) {
  //       String fieldName = fieldNames[i];
  //       dynamic fieldValue = fieldValues[i];

  //       if (fieldValue is dio.MultipartFile) {
  //         // If the fieldValue is already a MultipartFile, add it as is
  //         formData.files.add(
  //           MapEntry(fieldName, fieldValue),
  //         );
  //       } else if (fieldValue is File) {
  //         // If the fieldValue is a File, create a MultipartFile from it and add it
  //         formData.files.add(
  //           MapEntry(
  //             fieldName,
  //             await dio.MultipartFile.fromFile(fieldValue.path),
  //           ),
  //         );
  //       } else if (fieldValue is String && _isImageFile(fieldValue)) {
  //         // If the fieldValue is a String and it represents an image file path, add it as a MultipartFile
  //         formData.files.add(
  //           MapEntry(
  //             fieldName,
  //             await dio.MultipartFile.fromFile(fieldValue),
  //           ),
  //         );
  //       } else {
  //         // If it's not an image file or MultipartFile, add it as a regular field
  //         formData.fields.add(
  //           MapEntry(fieldName, fieldValue.toString()),
  //         );
  //       }
  //     }

  //     Response response = await dioClient.post(
  //       AppConstants.flutterWaveUri,
  //       data: formData,
  //       options: Options(headers: {
  //         'Content-Type': 'multipart/form-data',
  //         "Authorization": "Bearer ${sharedPreferences.getString(AppConstants.token)}",
  //       }),
  //     );

  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
}
