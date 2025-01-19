import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helper{
  static showSnackBar(apiResponse){
       Get.snackbar(
          'Message',
          '${apiResponse.response!.data["message"]}',
          backgroundColor: apiResponse.response!.data["message"] == "success"
              ? Colors.green
              : Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          shouldIconPulse: true,
          icon: Icon(
              apiResponse.response!.data["message"] == "success"
                  ? Icons.check
                  : Icons.cancel,
              color: Colors.white),
          barBlur: 10,
        );
  }
}