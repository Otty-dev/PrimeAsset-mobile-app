import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/model/response_model/payout_model.dart';
import 'package:clutch/data/model/response_model/paystack_bank_data_model.dart';
import 'package:clutch/data/repository/payout_repo.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/screens/history/payout_history_screen.dart';
import 'package:clutch/view/screens/menu/menu_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../data/model/response_model/payout_bank_form_model.dart';
import '../utils/helper.dart';
import '../view/screens/auth/login_screen.dart';
import '../view/screens/menu/address_verification_screen.dart';
import '../view/screens/kyc/identity_verification_screen.dart';
import '../view/verify_required/mail_verification_screen.dart';
import '../view/verify_required/sms_verification_screen.dart';
import '../view/verify_required/two_factor_verification_screen.dart';
import 'auth_controller.dart';

class PayoutController extends GetxController {
  final PayoutRepo payoutRepo;

  PayoutController({required this.payoutRepo});

  dynamic _status;

  dynamic get status => _status;
  PayoutData? _message;

  PayoutData? get message => _message;

  PayoutBankFormData? _messageBankData;

  PayoutBankFormData? get messageBankData => _messageBankData;

  PayStackBankData? _messagePayStackBankData;

  PayStackBankData? get messagePayStackBankData => _messagePayStackBankData;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingPayoutBank = false;

  bool get isLoadingPayoutBank => _isLoadingPayoutBank;

  bool _isLoadingPayStack = false;

  bool get isLoadingPayStack => _isLoadingPayStack;

  bool _isLoadingPayoutRequest = false;

  bool get isLoadingPayoutRequest => _isLoadingPayoutRequest;

  PayoutModel payoutModel = PayoutModel();
  PayoutBankFormModel payoutBankFormModel = PayoutBankFormModel();
  PayStackBankDataModel payStackBankDataModel = PayStackBankDataModel();

  var selectedCurrencyController = TextEditingController();
  dynamic selectedCurrency;

  dynamic bankNameFlutterWave;
  dynamic supportedCurrencyFlutterWave;
  dynamic convertRateFlutterWave;

  dynamic selectedBank;
  dynamic selectedPayStackBank;
  dynamic inputFieldsData;

  dynamic selectedBankNameFlutterWave;
  dynamic selectedSupportedCurrencyFlutterWave;

  dynamic selectedPayStackBankData;

  // Declare a map to store the form fields for each gateway
  final Map<String, RxList<Widget>> gatewayFormFields = {};
  final Map<String, List<DropdownMenuItem<String>>> gatewaySupportedCurrencies =
      {};
  List<Gateway> filteredGatewaysList = [];
  Map<String, TextEditingController> textControllers = {};
  final TextEditingController amountController = TextEditingController();
  List<dynamic> supportedCurrencyList = [];
  List<dynamic> flutterwaveBankList = [];
  List<dynamic> flutterwaveBankTransferList = [];
  List<ReceivableCurrencies> receivableCurrencyList = [];
  String? selectedTransferName;
  String? selectedFlutterwaveBankName;
  String? selectedCurrencyName;
  ReceivableCurrencies? receivableCurrency;
  Gateway? selectedGateway;
  Map<String, File?> pickedFiles = {};
  dynamic trxId;

  @override
  void onInit() {
    getPayoutData();
    super.onInit();
  }

  // get gateway params from selectedService
  void storeGatewayParameters() {
    if (selectedGateway != null &&
        selectedGateway!.parameters!.runtimeType.toString() !=
            "List<dynamic>") {
      for (var fieldName in selectedGateway!.parameters!.entries) {
        textControllers[fieldName.key] = TextEditingController();
      }
      update();
    }
  }

  // filter services by country name
  void filterSupportedCurrencies(String gateway) async {
    print("filter supported currency: -----------> $gateway");
    var currencies =
        filteredGatewaysList.where((item) => item.code == gateway).toList();
    print("filter supported currency: -----------> $currencies");
    supportedCurrencyList = [];
    supportedCurrencyList = currencies[0].supportedCurrency!;

    receivableCurrencyList = [];
    receivableCurrencyList = currencies[0].receivableCurrencies!;

    if (kDebugMode) {
      print("supportedCurrencyList ------> $supportedCurrencyList");
    }
    if (kDebugMode) {
      print(
          "receivableCurrencyList ------> ${currencies[0].receivableCurrencies!}");
    }
    update();
  }

  // Observable variable for pickedImage
  dynamic pickedImage;

  Future<void> pickImage() async {
    // Request storage permission
    // final storageStatus = await Permission.storage.request();

    // if (storageStatus.isGranted) {
    final picker = ImagePicker();
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      update();
      if (kDebugMode) {
        print("Image Path${pickedImage!.path}");
      }
    }
    // Refresh the widget to show the selected image
    // }
  }

  selectionClear() {
    selectedCurrency = null;
    update();
  }

  dynamic fieldNames = [].toSet().toList();
  dynamic fieldValues = [].toSet().toList();

  dynamic selectedFilePath;

  ///Get Payout Data
  Future<void> getPayoutData() async {
    _isLoading = true;
    update();
    ApiResponse apiResponse = await payoutRepo.getPayoutData();

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
          if (apiResponse.response!.data["status"] == "success") {
            payoutModel = PayoutModel.fromJson(apiResponse.response!.data!);
            _message = payoutModel.message;

            filteredGatewaysList = _message!.gateways!;

            for (var gateway in filteredGatewaysList) {
              if (gateway.name == 'Flutterwave') {
                flutterwaveBankList = gateway.banks!;
              }
            }

            if (_message!.gateways!.isNotEmpty) {
              for (var i in _message!.gateways!) {
                if (i.name == "Flutterwave") {
                  bankNameFlutterWave = i.name;
                  supportedCurrencyFlutterWave = i.supportedCurrency;
                }
              }
            }

            // Clear the existing form fields for each gateway
            gatewayFormFields.clear();
            selectedCurrency = null;
          } else {
            Get.offAll(() => MenuScreen());
            Get.snackbar(
              'Message',
              '${apiResponse.response!.data["message"]}',
              backgroundColor: apiResponse.response!.data["status"] != "success"
                  ? Colors.red
                  : Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
              margin: EdgeInsets.all(10),
              borderRadius: 8,
              barBlur: 10,
            );
          }
        }
      } else {
        _isLoading = false;
        update();
      }
    }
  }

  ///Get Bank Data
  Future<dynamic> getPayoutBankFormData(dynamic bankName) async {
    _isLoadingPayoutBank = true;
    update();
    ApiResponse apiResponse = await payoutRepo.getPayoutBankFormData(bankName);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutBank = false;
      update();
      if (apiResponse.response!.data != null) {
        _messageBankData = null;
        inputFieldsData = null;
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
          inputFieldsData = apiResponse.response!.data["message"]["input_form"];

          print(inputFieldsData);

          inputFieldsData.forEach((String key, dynamic value) {
            textControllers[key] = TextEditingController(text: "");
            print(key);
          });

          payoutBankFormModel =
              PayoutBankFormModel.fromJson(apiResponse.response!.data!);
          _messageBankData = payoutBankFormModel.message;

          flutterwaveBankTransferList.clear();
          // flutterwaveBankTransferList = List<dynamic>.from(payoutBankFormModel.message!.bank!.data as Iterable);
          Set<String> bankNames = {};

          for (var bank in payoutBankFormModel.message!.bank!.data!) {
            // Check if the bank name is already in the set
            if (!bankNames.contains(bank.name)) {
              bankNames.add(bank.name);
              flutterwaveBankTransferList.add(bank);
            }
          }
        }
      }
    } else {
      _isLoadingPayoutBank = false;
      update();
    }
  }

  ///Get PayStack Dropdown Data
  Future<dynamic> getPayStackBankData(dynamic currencyCode) async {
    _isLoadingPayoutRequest = true;
    update();
    ApiResponse apiResponse =
        await payoutRepo.getPayStackDropDownData(currencyCode);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutRequest = false;
      update();
      if (apiResponse.response!.data != null) {
        _messagePayStackBankData = null;
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
        } else if (apiResponse.response!.data["message"] ==
            "address verification required.") {
          Get.offAll(() => AddressVerificationScreen(isFromVerification: true));
          Helper.showSnackBar(apiResponse);
        } else if (apiResponse.response!.data["message"] ==
            "Identity verification required.") {
          Get.offAll(
              () => IdentityVerificationScreen(isFromVerification: true));
          Helper.showSnackBar(apiResponse);
        } else {
          update();
          if (kDebugMode) {
            print(inputFieldsData);
          }
          payStackBankDataModel =
              PayStackBankDataModel.fromJson(apiResponse.response!.data!);
          _messagePayStackBankData = payStackBankDataModel.message;
          _isLoadingPayoutRequest = false;
          update();
          return true;
        }
      }
    } else {
      _isLoadingPayoutRequest = false;
      update();
    }
  }

  // payout request
  Future<dynamic> payoutRequest(dynamic walletType, dynamic amount,
      dynamic gatewayId, dynamic supportedCurrency) async {
    _isLoadingPayoutRequest = true;
    update();
    ApiResponse apiResponse = await payoutRepo.payoutRequest(
        walletType, amount, gatewayId, supportedCurrency);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutRequest = false;
      update();
      print(
          "apiResponse.response!.data ---------------------> ${apiResponse.response!.data}");
      if (apiResponse.response!.data != null) {
        Map map = apiResponse.response!.data;
        final String status = map["status"];

        if (status.toLowerCase() == 'success') {
          trxId = map['data']['trx_id'];
          return trxId;
        } else {
          Get.snackbar(
            status,
            map['message'],
            backgroundColor: status != "success" ? Colors.red : Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(10),
            borderRadius: 8,
            barBlur: 10,
          );
        }

        update();
      }
    } else {
      _isLoadingPayoutRequest = false;
      update();
    }
  }

  /// manualPayment Submit
  Future<dynamic> payoutConfirm(BuildContext context) async {
    _isLoadingPayoutRequest = true;
    update();
    ApiResponse apiResponse =
        await payoutRepo.payoutConfirm(trxId, pickedFiles, textControllers);

    print(apiResponse.response!.data);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutRequest = false;
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
                    builder: (context) => PayoutHistoryScreen(
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
                            "Payout request send",
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
      _isLoadingPayoutRequest = false;
      update();
    }
  }

  /// manualPayment Submit
  Future<dynamic> flutterwavePayoutConfirm(BuildContext context) async {
    _isLoadingPayoutRequest = true;
    update();
    ApiResponse apiResponse = await payoutRepo.flutterwavePayoutConfirm(
        trxId,
        selectedCurrencyName,
        selectedTransferName,
        selectedFlutterwaveBankName,
        pickedFiles,
        textControllers);

    print(apiResponse.response!.data);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutRequest = false;
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
                    builder: (context) => PayoutHistoryScreen(
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
                            "Payout request send",
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
      _isLoadingPayoutRequest = false;
      update();
    }
  }

  Future<dynamic> paystackConfirm(BuildContext context) async {
    _isLoadingPayoutRequest = true;
    update();
    ApiResponse apiResponse = await payoutRepo.paystackConfirm(
        trxId,
        selectedCurrencyName,
        selectedTransferName,
        selectedPayStackBank,
        pickedFiles,
        textControllers);

    print(apiResponse.response!.data);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingPayoutRequest = false;
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
                    builder: (context) => PayoutHistoryScreen(
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
                            "Payout request send",
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
      _isLoadingPayoutRequest = false;
      update();
    }
  }

  /// FlutterWave Payout Request
  // Future<dynamic> flutterwavePayoutConfirm(
  //   BuildContext context,
  //   dynamic walletType,
  //   dynamic gateway,
  //   dynamic amount,
  //   List<dynamic> fieldNames,
  //   List<dynamic> fieldValues, {
  //   dynamic currencyCode,
  //   dynamic bank,
  //   dynamic transferName,
  // }) async {
  //   _isLoadingPayoutRequest = true;
  //   update();
  //   ApiResponse apiResponse = await payoutRepo.flutterWavePayoutRequest(
  //       walletType, gateway, amount, fieldNames, fieldValues,
  //       currencyCode: currencyCode, transferName: transferName, bank: bank);
  //   if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
  //     _isLoadingPayoutRequest = false;
  //     update();
  //     if (apiResponse.response!.data != null) {
  //       if (apiResponse.response!.data["message"] == "Email Verification Required") {
  //         Get.offAllNamed(MailVerificationScreen.routeName);
  //       } else if (apiResponse.response!.data["message"] == "Mobile Verification Required") {
  //         Get.offAllNamed(SmsVerificationScreen.routeName);
  //       } else if (apiResponse.response!.data["message"] == "Two FA Verification Required") {
  //         Get.offAllNamed(TwoFactorVerificationScreen.routeName);
  //       } else if (apiResponse.response!.data["message"] == "Your account has been suspend") {
  //         Get.find<AuthController>().removeUserToken();
  //         await Get.offNamedUntil(LoginScreen.routeName, (route) => false);
  //       } else if (apiResponse.response!.data["message"] == "Address verification required.") {
  //         Get.offAll(() => AddressVerificationScreen(isFromVerification: true));
  //         Helper.showSnackBar(apiResponse);
  //       } else if (apiResponse.response!.data["message"] == "Identity verification required.") {
  //         Get.offAll(() => IdentityVerificationScreen(isFromVerification: true));
  //         Helper.showSnackBar(apiResponse);
  //       } else {
  //         Map map = apiResponse.response!.data;
  //         dynamic msg;
  //         msg = map["message"];
  //         dynamic status;
  //         status = map["status"];
  //         if (status == "success") {
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => PayoutHistoryScreen(
  //                         status: "true",
  //                       )),
  //               (route) => false);
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 content: Container(
  //                   height: 260.h,
  //                   width: 260.w,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       children: [
  //                         Lottie.asset("assets/images/success.json"),
  //                         SizedBox(
  //                           height: 8.h,
  //                         ),
  //                         Text(
  //                           "Payout request send",
  //                           style: GoogleFonts.publicSans(
  //                             fontSize: 16.sp,
  //                             fontWeight: FontWeight.w500,
  //                             color: AppColors.getTextDarkLight(),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           height: 20.h,
  //                         ),
  //                         Align(
  //                           alignment: Alignment.center,
  //                           child: Padding(
  //                             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
  //                             child: InkWell(
  //                               onTap: () {
  //                                 Navigator.pop(context);
  //                               },
  //                               child: Container(
  //                                 width: 100.w,
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(5),
  //                                   color: AppColors.appDashBoardTransactionGreen,
  //                                 ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  //                                   child: Center(
  //                                     child: Text(
  //                                       "Ok",
  //                                       style: GoogleFonts.publicSans(
  //                                         fontWeight: FontWeight.w500,
  //                                         color: AppColors.appWhiteColor,
  //                                         fontSize: 16.sp,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         } else {
  //           Get.snackbar(
  //             'Message',
  //             '${msg}',
  //             backgroundColor: status != "success" ? Colors.red : Colors.green,
  //             colorText: Colors.white,
  //             duration: Duration(seconds: 2),
  //             snackPosition: SnackPosition.BOTTOM,
  //             margin: EdgeInsets.all(10),
  //             borderRadius: 8,
  //             barBlur: 10,
  //           );
  //         }
  //         update();
  //         if (kDebugMode) {
  //           print(inputFieldsData);
  //         }
  //       }
  //     }
  //   } else {
  //     _isLoadingPayoutRequest = false;
  //     update();
  //   }
  // }
}
