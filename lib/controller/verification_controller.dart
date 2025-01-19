import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/auth_controller.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/model/response_model/kyc_model.dart';
import 'package:clutch/data/repository/verification_repo.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/screens/auth/login_screen.dart';
import 'package:clutch/view/screens/kyc/identity_verification_list_screen.dart';
import 'package:clutch/view/verify_required/mail_verification_screen.dart';
import 'package:clutch/view/verify_required/sms_verification_screen.dart';
import 'package:clutch/view/verify_required/two_factor_verification_screen.dart';
import 'package:lottie/lottie.dart';

class VerificationController extends GetxController {
  final VerificationRepo verificationRepo;
  VerificationController({required this.verificationRepo});

  Map<String, TextEditingController> textControllers = {};
  Map<String, File?> pickedFiles = {};

  VerificationModel? _message;
  VerificationModel? get message => _message;
  String? submissionStatus;
  // VerificationModel verificationModel = VerificationModel(id: null);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isScreenLoading = false;
  bool get isScreenLoading => _isScreenLoading;

  bool _isIdentityLoading = false;
  bool get isIdentityLoading => _isIdentityLoading;
  List<VerificationModel> verificationData = [];
  List<KycData> kycSubmissionList = [];

  @override
  void onInit() {
    getKycData();
    getKycSubmissionList();
    super.onInit();
  }

  /// Get kyc data
  Future<dynamic> getKycData() async {
    _isScreenLoading = true;
    update();
    ApiResponse apiResponse = await verificationRepo.getKycData();

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isScreenLoading = false;
      update();
      if (apiResponse.response!.data != null) {
        _message = null;
        update();
        if (apiResponse.response!.data != null) {
          // if (apiResponse.response!.data["message"] == "Email Verification Required") {
          //   Get.offAllNamed(MailVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Mobile Verification Required") {
          //   Get.offAllNamed(SmsVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Two FA Verification Required") {
          //   Get.offAllNamed(TwoFactorVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Your account has been suspend") {
          //   Get.find<AuthController>().removeUserToken();
          //   await Get.offNamedUntil(LoginScreen.routeName, (route) => false);
          // } else if (apiResponse.response!.data["message"] == "Address verification required.") {
          //   Get.offAll(() => AddressVerificationScreen(isFromVerification: true));
          //   Helper.showSnackBar(apiResponse);
          // } else if (apiResponse.response!.data["message"] == "Identity verification required.") {
          //   Get.offAll(() => IdentityVerificationScreen(isFromVerification: true));
          //   Helper.showSnackBar(apiResponse);
          // } else {
          List<dynamic> data = apiResponse.response!.data!;
          verificationData =
              data.map((item) => VerificationModel.fromJson(item)).toList();
          for (var item in verificationData) {
            for (var key in item.inputForm.keys) {
              textControllers[key] = TextEditingController();
            }
          }
          update();
          // }
        }
      }
    } else {
      _isScreenLoading = false;
      update();
    }
  }

  Future<dynamic> verificationSubmit(
      dynamic kycId, BuildContext context) async {
    _isLoading = true;
    update();
    ApiResponse apiResponse = await verificationRepo.verificationSubmit(
        kycId, pickedFiles, textControllers);

    print(apiResponse.response!.data);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
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
        } else {
          Map map = apiResponse.response!.data;
          dynamic msg;
          msg = map["message"];
          dynamic status;
          status = map["status"];
          if (status != "success") {
            Get.snackbar(
              'Message',
              '$msg',
              backgroundColor: status != "success" ? Colors.red : Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(10),
              borderRadius: 8,
              barBlur: 10,
            );
          }
          if (status == "success") {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => KycSubmissionListScreen(
                          status: "true",
                        )),
                (route) => false);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Container(
                    height: 260.h,
                    width: 260.w,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Lottie.asset("assets/images/success.json"),
                          SizedBox(
                            height: 8.h,
                          ),
                          Text(
                            "Kyc submitted successfully",
                            style: GoogleFonts.publicSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextDarkLight(),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 5),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color:
                                        AppColors.appDashBoardTransactionGreen,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: Center(
                                      child: Text(
                                        "Ok",
                                        style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.appWhiteColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            Get.snackbar(
              'Message',
              '${msg}',
              backgroundColor: status != "success" ? Colors.red : Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: EdgeInsets.all(10),
              borderRadius: 8,
              barBlur: 10,
            );
          }
        }
        update();
      }
    } else {
      _isLoading = false;
      update();
    }
  }

  /// Get kyc data
  Future<dynamic> getKycSubmissionList() async {
    _isScreenLoading = true;
    update();
    ApiResponse apiResponse = await verificationRepo.getKycSubmissionList();

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isScreenLoading = false;
      update();
      if (apiResponse.response!.data != null) {
        _message = null;
        update();
        if (apiResponse.response!.data != null) {
          // if (apiResponse.response!.data["message"] == "Email Verification Required") {
          //   Get.offAllNamed(MailVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Mobile Verification Required") {
          //   Get.offAllNamed(SmsVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Two FA Verification Required") {
          //   Get.offAllNamed(TwoFactorVerificationScreen.routeName);
          // } else if (apiResponse.response!.data["message"] == "Your account has been suspend") {
          //   Get.find<AuthController>().removeUserToken();
          //   await Get.offNamedUntil(LoginScreen.routeName, (route) => false);
          // } else if (apiResponse.response!.data["message"] == "Address verification required.") {
          //   Get.offAll(() => AddressVerificationScreen(isFromVerification: true));
          //   Helper.showSnackBar(apiResponse);
          // } else if (apiResponse.response!.data["message"] == "Identity verification required.") {
          //   Get.offAll(() => IdentityVerificationScreen(isFromVerification: true));
          //   Helper.showSnackBar(apiResponse);
          // } else {
          print(
              "apiResponse.response!.data! ${apiResponse.response!.data["data"]}");
          List<dynamic> data = apiResponse.response!.data!["data"];
          kycSubmissionList =
              data.map((item) => KycData.fromJson(item)).toList();
          update();
          // }
        }
      }
    } else {
      _isScreenLoading = false;
      update();
    }
  }
}
