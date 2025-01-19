import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasource/remote/dio/dio_client.dart';
import '../datasource/remote/exception/api_error_handler.dart';
import '../model/base_model/api_response.dart';

class VerificationRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  VerificationRepo({required this.dioClient, required this.sharedPreferences});

  /// Get Plan Data
  Future<ApiResponse> getKycData() async {
    print(AppConstants.getKycUri);
    try {
      Response response = await dioClient.get(
        "${AppConstants.getKycUri}",
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

  Future<ApiResponse> getKycSubmissionList() async {
    print(AppConstants.getKycUri);
    try {
      Response response = await dioClient.get(
        "${AppConstants.getKycSubmissionListUri}",
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

  Future<ApiResponse> verificationSubmit(
      dynamic kycId,
      Map<String, File?> pickedFiles,
      Map<String, TextEditingController> textControllers) async {
    try {
      // Add text field values to formData
      FormData formData = FormData.fromMap({
        'kyc_id': kycId,
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
        "${AppConstants.getKycSubmissionUri}",
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          "Authorization":
              "Bearer ${sharedPreferences.getString(AppConstants.token)}",
        }),
      );
      print("kyc response --------------------> $response");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
