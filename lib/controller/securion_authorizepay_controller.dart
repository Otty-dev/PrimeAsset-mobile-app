import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clutch/controller/auth_controller.dart';
import 'package:clutch/controller/dashboard_controller.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/repository/securion_authorizepay_repo.dart';
import 'package:clutch/view/screens/auth/login_screen.dart';
import 'package:clutch/view/screens/history/deposit_history_screen.dart';
import 'package:clutch/view/verify_required/mail_verification_screen.dart';
import 'package:clutch/view/verify_required/sms_verification_screen.dart';
import 'package:clutch/view/verify_required/two_factor_verification_screen.dart';
import '../utils/helper.dart';
import '../view/screens/kyc/identity_verification_screen.dart';

class SecurionPayAuthorizenetController extends GetxController {
  final SecurionPayAuthorizenetRepo securionPayAuthorizenetRepo;

  RxBool isLoading = false.obs;

  SecurionPayAuthorizenetController(
      {required this.securionPayAuthorizenetRepo});

  Future<dynamic> cardPaymentRequest(
      dynamic trxId,
      dynamic amount,
      dynamic gateway,
      dynamic cardNumber,
      dynamic cardName,
      dynamic expiryMonth,
      dynamic expiryYear,
      dynamic cardCVC,
      BuildContext context) async {
    isLoading.value = true;
    update();
    ApiResponse apiResponse =
        await securionPayAuthorizenetRepo.cardPaymentRequest(trxId, amount,
            gateway, cardNumber, cardName, expiryMonth, expiryYear, cardCVC);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      isLoading.value = false;
      update();
      if (apiResponse.response!.data != null) {
        if (apiResponse.response!.data["message"] ==
            "Email Verification Required") {
          Get.offAllNamed(MailVerificationScreen.routeName);
        } else if (apiResponse.response!.data["message"] ==
            "Mobile Verification Required") {
          Get.offAllNamed(SmsVerificationScreen.routeName);
        } else if (apiResponse.response!.data["message"] ==
            "Two FA Verification Required") {
          Get.offAllNamed(TwoFactorVerificationScreen.routeName);
        } else if (apiResponse.response!.data["message"] ==
            "Your account has been suspend") {
          Get.find<AuthController>().removeUserToken();
          await Get.offNamedUntil(LoginScreen.routeName, (route) => false);
        } else if (apiResponse.response!.data["status"] ==
            "verificationError") {
          Get.offAll(
              () => IdentityVerificationScreen(isFromVerification: true));
          Helper.showSnackBar(apiResponse);
        } else {
          dynamic status = apiResponse.response!.data['status'];
          dynamic msg = apiResponse.response!.data['message'];

          if (status == "success") {
            Get.find<DashBoardController>().getDashBoardData().then((value) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DepositHistoryScreen(
                            status: "true",
                          )),
                  (route) => false);
            });
            Get.snackbar(
              'Message',
              '$msg',
              backgroundColor: status == "success" ? Colors.green : Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(10),
              borderRadius: 8,
              shouldIconPulse: true,
              icon: Icon(status == "success" ? Icons.check : Icons.cancel,
                  color: Colors.white),
              barBlur: 10,
            );
          } else {
            Get.snackbar(
              'Message',
              '$msg',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(10),
              borderRadius: 8,
              shouldIconPulse: true,
              icon: const Icon(Icons.cancel, color: Colors.white),
              barBlur: 10,
            );
          }

          update();
        }
      }
    } else {
      isLoading.value = false;
      update();
    }
  }
}
