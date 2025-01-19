import 'package:get/get.dart';
import 'package:clutch/controller/auth_controller.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/model/response_model/referral_model.dart';
import 'package:clutch/data/repository/referral_repo.dart';
import 'package:clutch/view/screens/auth/login_screen.dart';
import 'package:clutch/view/verify_required/mail_verification_screen.dart';
import 'package:clutch/view/verify_required/sms_verification_screen.dart';
import 'package:clutch/view/verify_required/two_factor_verification_screen.dart';
import '../utils/helper.dart';
import '../view/screens/kyc/identity_verification_screen.dart';

class ReferralController extends GetxController {
  final ReferralRepo referralRepo;

  ReferralController({required this.referralRepo});

  String? _status;
  String? get status => _status;
  ReferralData? _message;
  ReferralData? get message => _message;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReferralModel referralModel = ReferralModel();

  Future<dynamic> getReferralData() async {
    _isLoading = true;
    update();
    ApiResponse apiResponse = await referralRepo.getReferralData();

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      update();
      if (apiResponse.response!.data != null) {
        _message = null;
        update();
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
          referralModel = ReferralModel.fromJson(apiResponse.response!.data!);
          _message = referralModel.message;
          update();
        }
      }
    } else {
      _isLoading = false;
      update();
    }
  }

  @override
  void onInit() {
    getReferralData();
    super.onInit();
  }
}
