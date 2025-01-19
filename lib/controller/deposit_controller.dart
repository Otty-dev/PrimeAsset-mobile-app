import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/auth_controller.dart';
import 'package:clutch/controller/deposit_history_controller.dart';
import 'package:clutch/controller/my_account_controller.dart';
import 'package:clutch/controller/payment_done_controller.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/model/response_model/payment_method_model.dart';
import 'package:clutch/data/repository/deposit_repo.dart';
import 'package:http/http.dart' as http;
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'package:clutch/view/screens/history/deposit_history_screen.dart';
import 'package:clutch/view/verify_required/mail_verification_screen.dart';
import 'package:clutch/view/verify_required/sms_verification_screen.dart';
import 'package:clutch/view/verify_required/two_factor_verification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:monnify_flutter_sdk_plus/monnify_flutter_sdk_plus.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/helper.dart';
import '../view/screens/auth/login_screen.dart';
import '../view/screens/menu/address_verification_screen.dart';
import '../view/screens/kyc/identity_verification_screen.dart';
import '../view/widgets/app_payment_success.dart';

class DepositController extends GetxController {
  final DepositRepo? depositScreenRepo;

  DepositController({this.depositScreenRepo});

  final amountController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingManualPay = false;
  bool get isLoadingManualPay => _isLoadingManualPay;

  bool _isLoadingOtherPay = false;
  bool get isLoadingOtherPay => _isLoadingOtherPay;

  dynamic _status;
  PaymentGatewayData? _message;

  dynamic get status => _status;

  List<Gateway>? _gateways;
  PaymentGatewayData? message;
  List<Gateway>? get gateways => _gateways;

  // --------------------------
  List<Gateway> filteredGatewaysList = [];
  List<dynamic> supportedCurrencyList = [];
  List<ReceivableCurrencies> receivableCurrencyList = [];
  String? selectedCurrencyName;
  ReceivableCurrencies? receivableCurrency;
  Map<String, File?> pickedFiles = {};
  Map<String, TextEditingController> textControllers = {};
  Gateway? selectedGateway;

  // get gateway params from selectedService
  void storeGatewayParameters() {
    if (selectedGateway != null) {
      for (var fieldName in selectedGateway!.parameters!.entries) {
        textControllers[fieldName.key] = TextEditingController();
      }
      update();
    }
  }

  // filter services by country name
  void filterSupportedCurrencies(String gateway) async {
    var currencies =
        filteredGatewaysList.where((item) => item.code == gateway).toList();
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
  // --------------------------

  PaymentMethodModel paymentMethodModel = PaymentMethodModel();

  PaystackPlugin payStackPlugin = PaystackPlugin();

  // Observable variable for pickedImage
  dynamic pickedImage;

  Future<void> pickImage() async {
    // Request storage permission
    // final storageStatus = await Permission.storage.request();

    // if (storageStatus.isGranted) {
    final picker = ImagePicker();
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kDebugMode) {
        print("Image Path: ${pickedImage!.path}");
      }
    }
    // } else {
    //   if (kDebugMode) {
    //     print("Permission Denied");
    //   }
    // }

    // Refresh the widget to show the selected image
    update();
  }

  @override
  void onInit() {
    selectedGateway = null;
    getPaymentMethodData();
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    plugin.initialize(publicKey: publicKeyPayStack ?? "${publicKeyTest}");
    Get.find<MyAccountController>().getAccountData();
    initMonnifySdk();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    razorpay!.clear();
  }

  dynamic fieldNames = [];
  dynamic fieldValuesList = [];

  dynamic selectedFilePath;
  RxList<Widget> formFields = <Widget>[].obs;
  Map<String, dynamic> fieldValues = {};

  //Stripe
  dynamic stripeSecretKey;
  dynamic stripePublisherKey;

  //Razorpay
  dynamic keyIdRazorPay;
  dynamic keySecretRazorPay;

  //Paytm
  dynamic midPaytm;
  dynamic merchantKeyPaytm;
  dynamic websitePaytm;
  dynamic industryTypePaytm;
  dynamic channelIdPaytm;
  dynamic transactionUrlPaytm;
  dynamic transactionStatusUrlPaytm;

  //FlutterWave
  dynamic publicKeyFlutterWave;
  dynamic secretKeyFlutterWave;
  dynamic encryptedKeyFlutterWave;

  //Paypal
  dynamic clientIdPaypal;
  dynamic secretKeyPaypal;

  //PayStack
  dynamic publicKeyPayStack;
  dynamic secretKeyPayStack;

  //Monnify
  dynamic apiKeyMonnify;
  dynamic secretKeyMonnify;
  dynamic contactCodeMonnfiy;

  dynamic calculateTotalAmount;
  dynamic calculateCharge;

  /// All Secret Key
  String manualPaymentNote = "";
  Future<void> getPaymentMethodData() async {
    try {
      _isLoading = true;
      update();
      ApiResponse apiResponse = await depositScreenRepo!.getPaymentMethodData();

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _isLoading = false;

        if (apiResponse.response!.data != null) {
          _message = null;

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
              "Address verification required.") {
            Get.offAll(
                () => AddressVerificationScreen(isFromVerification: true));
            Helper.showSnackBar(apiResponse);
          } else if (apiResponse.response!.data["message"] ==
              "Identity verification required.") {
            Get.offAll(
                () => IdentityVerificationScreen(isFromVerification: true));
            Helper.showSnackBar(apiResponse);
          } else {
            try {
              paymentMethodModel =
                  PaymentMethodModel.fromJson(apiResponse.response!.data!);
              // print("Payment Method Model: $paymentMethodModel");

              _message = paymentMethodModel.message;
              message = _message;

              _gateways = _message!.gateways;
              filteredGatewaysList = _gateways!;

              formFields.clear();
              textControllers.clear();
              fieldValuesList.clear();
            } catch (e) {
              print("Error parsing PaymentMethodModel: $e");
            }

            if (_gateways != null && _gateways!.isNotEmpty) {
              for (var gateway in _gateways!) {
                //Stripe
                if (gateway.code == "stripe") {
                  stripeSecretKey = gateway.parameters!['secret_key'];
                  stripePublisherKey = gateway.parameters!['publishable_key'];
                }

                //RazorPay
                if (gateway.code == "razorpay") {
                  keyIdRazorPay = gateway.parameters!['key_id'];
                  keySecretRazorPay = gateway.parameters!['key_secret'];
                }

                //Paytm
                if (gateway.code == "paytm") {
                  midPaytm = gateway.parameters!['MID'];
                  merchantKeyPaytm = gateway.parameters!['merchant_key'];
                  websitePaytm = gateway.parameters!['WEBSITE'];
                  industryTypePaytm = gateway.parameters!['INDUSTRY_TYPE_ID'];
                  channelIdPaytm = gateway.parameters!['CHANNEL_ID'];
                  transactionUrlPaytm = gateway.parameters!['transaction_url'];
                  transactionStatusUrlPaytm =
                      gateway.parameters!['transaction_status_url'];
                }

                //FlutterWave
                if (gateway.code == "flutterwave") {
                  publicKeyFlutterWave = gateway.parameters!['public_key'];
                  secretKeyFlutterWave = gateway.parameters!['secret_key'];
                  encryptedKeyFlutterWave =
                      gateway.parameters!['encryption_key'];
                }

                //Paypal
                if (gateway.code == "paypal") {
                  clientIdPaypal = gateway.parameters!['cleint_id'];
                  secretKeyPaypal = gateway.parameters!['secret'];
                }

                //PayStack
                if (gateway.code == "paystack") {
                  publicKeyPayStack = gateway.parameters!['public_key'];
                  secretKeyPayStack = gateway.parameters!['secret_key'];
                }

                //Monnify
                if (gateway.code == "monnify") {
                  apiKeyMonnify = gateway.parameters!['api_key'];
                  secretKeyMonnify = gateway.parameters!['secret_key'];
                  contactCodeMonnfiy = gateway.parameters!['contract_code'];
                }
              }

              update();
            }
          }
        }
      } else {
        _isLoading = false;
        _message = null;
        update();
      }
    } catch (error) {
      // Handle error
      _isLoading = false;
      _message = null;
      update();
    }
  }

  /// manualPayment Submit
  Future<dynamic> manualPaymentRequest(
      dynamic gateway, dynamic amount, BuildContext context) async {
    _isLoadingManualPay = true;
    update();
    ApiResponse apiResponse = await depositScreenRepo!.manualPaymentRepo(
        trxId, gateway, amount, pickedFiles, textControllers);

    print(apiResponse.response!.data);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingManualPay = false;
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
            Get.find<DepositHistoryController>()
                .getDepositHistorySearchData("", "", "", page: 1);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => DepositHistoryScreen(
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
                            "Deposit request send",
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
          }
        }
        update();
      }
    } else {
      _isLoadingManualPay = false;
      update();
    }
  }

  //Total Amount Calculate
  calculateTotal(dynamic amount, dynamic paymentMethod) {
    update();
    if (paymentMethod == "stripe") {
      double conversionRate = double.parse(
          selectedGateway!.receivableCurrencies![0].conversionRate.toString());
      String formattedRate =
          conversionRate.toStringAsFixed(2); // Round to 2 decimal places

      double convertedAmount = double.parse(amount) * conversionRate;
      int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

      double amountWithPercentageCharge = totalCents *
          (double.parse(selectedGateway!
                  .receivableCurrencies![0].percentageCharge
                  .toString()) /
              100);
      double totalAmountWithFixCharge = amountWithPercentageCharge +
          double.parse(selectedGateway!.receivableCurrencies![0].fixedCharge
              .toString()) +
          totalCents;

      int totalAmountAsInt =
          totalAmountWithFixCharge.toInt(); // Convert to integer

      if (kDebugMode) {
        print("Formatted Rate: $formattedRate");
        print("Converted Amount: $convertedAmount");
        print("Total in Cents: $totalCents");
        print("Amount with Percentage Charge: $amountWithPercentageCharge");
        print("Amount with Fix Charge: $totalAmountWithFixCharge");
        print("Total Amount as Integer: $totalAmountAsInt");
      }

      return totalAmountAsInt.toString();
    } else if (paymentMethod == "razorpay") {
      double conversionRate = double.parse(
          selectedGateway!.receivableCurrencies![0].conversionRate.toString());
      String formattedRate =
          conversionRate.toStringAsFixed(2); // Round to 2 decimal places

      double convertedAmount = double.parse(amount) * conversionRate;
      int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

      double amountWithPercentageCharge = totalCents *
          (double.parse(selectedGateway!
                  .receivableCurrencies![0].percentageCharge
                  .toString()) /
              100);
      double totalAmountWithFixCharge = amountWithPercentageCharge +
          double.parse(selectedGateway!.receivableCurrencies![0].fixedCharge
              .toString()) +
          totalCents;

      int totalAmountAsInt =
          totalAmountWithFixCharge.toInt(); // Convert to integer

      if (kDebugMode) {
        print("Formatted Rate: $formattedRate");
        print("Converted Amount: $convertedAmount");
        print("Total in Cents: $totalCents");
        print("Amount with Percentage Charge: $amountWithPercentageCharge");
        print("Amount with Fix Charge: $totalAmountWithFixCharge");
        print("Total Amount as Integer: $totalAmountAsInt");
      }

      return totalAmountAsInt.toString();
    }
  }

  dynamic totalStripePay;
  dynamic totalRazorPay;
  //showCalculateTotal
  showCalculateTotal(dynamic amount, dynamic paymentMethod) {
    update();
    if (paymentMethod == "stripe") {
      double conversionRate = double.parse(
          selectedGateway!.receivableCurrencies![0].conversionRate.toString());
      String formattedRate =
          conversionRate.toStringAsFixed(2); // Round to 2 decimal places

      double convertedAmount = double.parse(amount) * conversionRate;
      int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

      double amountWithPercentageCharge = totalCents *
          (double.parse(selectedGateway!
                  .receivableCurrencies![0].percentageCharge
                  .toString()) /
              100);
      double totalAmountWithFixCharge = amountWithPercentageCharge +
          double.parse(selectedGateway!.receivableCurrencies![0].fixedCharge
              .toString()) +
          totalCents;

      int totalAmountAsInt =
          totalAmountWithFixCharge.toInt(); // Convert to integer

      totalStripePay = totalAmountAsInt / 100;

      if (kDebugMode) {
        print("check....$totalStripePay");
      }

      if (kDebugMode) {
        print("Formatted Rate: $formattedRate");
        print("Converted Amount: $convertedAmount");
        print("Total in Cents: $totalCents");
        print("Amount with Percentage Charge: $amountWithPercentageCharge");
        print("Amount with Fix Charge: $totalAmountWithFixCharge");
        print("Total Amount as Integer: $totalAmountAsInt");
      }

      return totalStripePay.toString();
    } else if (paymentMethod == "razorpay") {
      print("check" +
          selectedGateway!.receivableCurrencies![0].conversionRate.toString());
      print(
          "check" + selectedGateway!.receivableCurrencies![0].name.toString());
      double conversionRate = double.parse(
          selectedGateway!.receivableCurrencies![0].conversionRate.toString());

      double convertedAmount = double.parse(amount) * conversionRate;
      dynamic totalCents = convertedAmount; // Convert to cents

      double amountWithPercentageCharge = totalCents /
          100 *
          double.parse(selectedGateway!
              .receivableCurrencies![0].percentageCharge
              .toString());
      double totalAmountWithFixCharge = amountWithPercentageCharge +
          double.parse(
              selectedGateway!.receivableCurrencies![0].fixedCharge.toString());

      int totalAmountAsInt =
          totalAmountWithFixCharge.toInt(); // Convert to integer

      totalRazorPay = totalAmountWithFixCharge;

      if (kDebugMode) {
        print("check....$totalRazorPay");
      }

      if (kDebugMode) {
        print("Converted Amount: $convertedAmount");
        print("Total in Cents: $totalCents");
        print("Amount with Percentage Charge: $amountWithPercentageCharge");
        print("Amount with Fix Charge: $totalAmountWithFixCharge");
        print("Total Amount as Integer: $totalAmountAsInt");
      }

      return totalRazorPay.toString();
    }
  }

  dynamic url;
  dynamic trxId;

  /// manualPayment Submit
  // Future<dynamic> sendOtherPaymentRequest(
  //   dynamic amount,
  //   dynamic gatewayId,
  // ) async {
  //   _isLoadingOtherPay = true;
  //   update();
  //   ApiResponse apiResponse = await depositScreenRepo!.sendOtherPaymentRequest(amount, gatewayId);

  //   if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
  //     _isLoadingOtherPay = false;
  //     update();
  //     if (apiResponse.response!.data != null) {
  //       Map map = apiResponse.response!.data;
  //       url = map["message"]["url"];
  //       print("Check>>>$url");

  //       update();
  //     }
  //   } else {
  //     _isLoadingOtherPay = false;
  //     update();
  //   }
  // }

  // deposit request
  Future<dynamic> sendDepositRequest(
      dynamic amount, dynamic gatewayId, dynamic supportedCurrency) async {
    _isLoadingOtherPay = true;
    update();
    ApiResponse apiResponse = await depositScreenRepo!
        .sendDepositRequest(amount, gatewayId, supportedCurrency);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingOtherPay = false;
      update();
      if (apiResponse.response!.data != null) {
        Map map = apiResponse.response!.data;

        trxId = map['data']['trx_id'];

        update();
      }
    } else {
      _isLoadingOtherPay = false;
      update();
    }
  }

  // deposit request
  Future<dynamic> sendBuyPlanRequest(dynamic planId, dynamic amount,
      dynamic gatewayId, dynamic supportedCurrency) async {
    _isLoadingOtherPay = true;
    update();
    ApiResponse apiResponse = await depositScreenRepo!
        .sendBuyPlanRequest(planId, amount, gatewayId, supportedCurrency);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoadingOtherPay = false;
      update();
      if (apiResponse.response!.data != null) {
        Map map = apiResponse.response!.data;

        trxId = map['original']['data']['trx_id'];

        update();
      }
    } else {
      _isLoadingOtherPay = false;
      update();
    }
  }

  Future<dynamic> getPaymentWebview(dynamic trxId) async {
    _isLoading = true;
    update();
    ApiResponse apiResponse = await depositScreenRepo!.getPaymentWebview(trxId);

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
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
      } else if (apiResponse.response!.data["message"] ==
          "Address verification required.") {
        Get.offAll(() => AddressVerificationScreen(isFromVerification: true));
        Helper.showSnackBar(apiResponse);
      } else if (apiResponse.response!.data["message"] ==
          "Identity verification required.") {
        Get.offAll(() => IdentityVerificationScreen(isFromVerification: true));
        Helper.showSnackBar(apiResponse);
      } else {
        url = apiResponse.response!.data['message']['url'];
        update();
      }
    } else {
      _isLoading = false;
      update();
    }
  }

  ///Stripe Payment Integration
  ///Start Implementation*********
  dynamic stripePaymentData;
  var stripe = Stripe.instance;

  Future<void> stripeDepositRequest(
      dynamic planId, BuildContext context) async {
    try {
      if (kDebugMode) {
        print(selectedGateway!.receivableCurrencies![0].name ?? '');
      }
      stripePaymentData = await stripePaymentCreate(
          calculateTotal(amountController.text.toString(), 'stripe'),
          '${selectedGateway!.receivableCurrencies![0].name}');
      await stripe.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: stripePaymentData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Test',
        ),
      );
      displayPaymentSheet(planId, context);
      update();
    } catch (e, s) {
      if (kDebugMode) {
        print('Payment exception: $e$s');
      }
    }
  }

  displayPaymentSheet(dynamic planId, BuildContext context) async {
    try {
      await stripe.presentPaymentSheet().then((newValue) {
        if (kDebugMode) {
          print('payment intent ${stripePaymentData['id']}');
          print('payment intent ${stripePaymentData['client_secret']}');
          print('payment intent ${stripePaymentData['amount']}');
          print('payment intent $stripePaymentData');
        }

        Get.find<PaymentDoneController>()
            .paymentDoneRequest(
                trxId, selectedGateway!.id, amountController.text.toString())
            .then((value) {
          if (kDebugMode) {
            print("Success");
          }
        }).then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DepositHistoryScreen(
                        status: "true",
                      )),
              (route) => false);
          Get.dialog(AppPaymentSuccess());
        });
        stripePaymentData = null;
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
        }
      });
    } on StripeException catch (e) {
      if (kDebugMode) {
        print('Exception/DISPLAYPAYMENTSHEET==> $e');
      }
      Get.dialog(
        const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('$e');
      }
    }
  }

  final secretKeyStripe =
      "sk_test_51NayeVFRHqwLPZjYZ1dVv7StS1oClKjDotCAe0aq0U6Ltk8TSqpOy29GXR6VnLY4526oZYSD8TGDaoNbUeDvk4Y500FAGkLmOR";

  stripePaymentCreate(
    String amount,
    String currency,
  ) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer ' + "${secretKeyStripe}",
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (kDebugMode) {
        print(response.body);
      }
      return jsonDecode(response.body);
    } catch (err) {
      if (kDebugMode) {
        print('err charging user: ${err.toString()}');
      }
      return {};
    }
  }

  ///End Implementation**********/

  ///RazorPay Payment Integration
  ///Start Implementation*********
  Razorpay? razorpay;
  var isPaymentSuccess = false.obs;
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    isPaymentSuccess.value = true;
    if (kDebugMode) {
      print(isPaymentSuccess.value);
    }
    if (isPaymentSuccess.value == true) {
      Get.find<PaymentDoneController>()
          .paymentDoneRequest(
              trxId, selectedGateway!.id, amountController.text.toString())
          .then((value) {
        if (kDebugMode) {
          print("Success");
        }
      }).then((value) {
        Get.toNamed(DepositHistoryScreen.routeName);
        Get.dialog(AppPaymentSuccess());
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payment
  }
  void razorPayPaymentRequest() {
    final options = {
      // Replace with your actual Razorpay key
      'key': 'rzp_test_kKtwjQz2zCm6Qp',
      'amount': calculateTotal(amountController.text.toString(), 'razorpay'),
      'name': 'Test',
      'description': 'Test Payment',
      'prefill': {'contact': '1234567890', 'email': 'test@gmail.com'},
      'external': {
        'wallets': ['paytm']
      },
      'currency': '${selectedGateway!.receivableCurrencies![0].name}'
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  ///End Implementation**********/

  ///FlutterWave Payment Integration
  ///Start Implementation*********
  flutterWavePaymentRequest(BuildContext context, dynamic planId) {
    handleFlutterWavePaymentInitialization(context, planId);
  }

  handleFlutterWavePaymentInitialization(
      BuildContext context, dynamic planId) async {
    final Customer customer = Customer(
        email:
            "${Get.find<MyAccountController>().myAccountModel.message!.userEmail ?? "test@gmail.com"}",
        name:
            '${Get.find<MyAccountController>().myAccountModel.message!.username ?? "test"}',
        phoneNumber: '123456789');

    final Flutterwave flutterWave = Flutterwave(
        context: context,
        publicKey:
            "${publicKeyFlutterWave ?? "FLWPUBK_TEST-1aa1ec3eda9729965fecb62eff8268c7-X"}",
        currency: '${selectedGateway!.receivableCurrencies![0].name}',
        redirectUrl: '${AppConstants.badgesUri}',
        amount: calculateFlutterWaveAmount(amountController.text.toString()),
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: "Payment"),
        isTestMode: true,
        txRef: getRandomString(15));
    final ChargeResponse response = await flutterWave.charge();
    if (kDebugMode) {
      print("${response.toJson()['success']}");
    }
    if (response.toJson()['success'] == true) {
      Get.find<PaymentDoneController>()
          .paymentDoneRequest(trxId, selectedGateway!.id,
              calculateTotal(amountController.text.toString(), 'razorpay'))
          .then((value) {
        if (kDebugMode) {
          print("Success");
        }
      }).then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => DepositHistoryScreen(
                      status: "true",
                    )),
            (route) => false);
        Get.dialog(AppPaymentSuccess());
      });
    }
  }

  calculateFlutterWaveAmount(dynamic amount) {
    double conversionRate = double.parse(
        selectedGateway!.receivableCurrencies![0].conversionRate.toString());
    String formattedRate =
        conversionRate.toStringAsFixed(2); // Round to 2 decimal places

    double convertedAmount = double.parse(amount) * conversionRate;
    int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

    double amountWithPercentageCharge = totalCents *
        (double.parse(selectedGateway!.receivableCurrencies![0].percentageCharge
                .toString()) /
            100);
    double totalAmountWithFixCharge = amountWithPercentageCharge +
        double.parse(
            selectedGateway!.receivableCurrencies![0].fixedCharge.toString()) +
        totalCents;

    int totalAmountAsInt =
        totalAmountWithFixCharge.toInt(); // Convert to integer

    if (kDebugMode) {
      print("Formatted Rate: $formattedRate");
      print("Converted Amount: $convertedAmount");
      print("Total in Cents: $totalCents");
      print("Amount with Percentage Charge: $amountWithPercentageCharge");
      print("Amount with Fix Charge: $totalAmountWithFixCharge");
      print("Total Amount as Integer: $totalAmountAsInt");
    }

    return totalAmountAsInt.toString();
  }

  ///End Implementation**********/

  ///MonnifySDK Payment Integration
  ///Start Implementation*********
  Future<void> initMonnifySdk() async {
    try {
      if (await MonnifyFlutterSdkPlus.initialize(
          '${apiKeyMonnify ?? "MK_TEST_LB5KJDYD65"}',
          '${contactCodeMonnfiy ?? "5566252118"}',
          ApplicationMode.TEST)) {
        if (kDebugMode) {
          print("SDK initialized!");
        }
      }
    } on PlatformException catch (e, s) {
      if (kDebugMode) {
        print("Error initializing sdk");
        print(e);
        print(s);
      }
      if (kDebugMode) {
        print("Failed to init sdk!");
      }
    }
  }

  Future<void> monnifyPaymentRequest(
      dynamic planId, BuildContext context) async {
    TransactionResponse transactionResponse;
    update();
    try {
      transactionResponse =
          await MonnifyFlutterSdkPlus.initializePayment(Transaction(
        calculateMonnifyAmount(amountController.text),
        '${selectedGateway!.receivableCurrencies![0].name}',
        "${Get.find<MyAccountController>().myAccountModel.message!.username ?? "Test Name"}",
        "${Get.find<MyAccountController>().myAccountModel.message!.userEmail ?? "mail.cus@tome.er"}",
        getRandomString(15),
        "Payment",
        metaData: {"ip": "196.168.45.22", "device": "mobile"},
        //  paymentMethods: [PaymentMethod.CARD, PaymentMethod.ACCOUNT_TRANSFER],
      ));

      if (kDebugMode) {
        print("Checked>>> ${transactionResponse.transactionStatus}");
      }
      if (transactionResponse.transactionStatus == "PAID") {
        Get.find<PaymentDoneController>()
            .paymentDoneRequest(
                trxId, selectedGateway!.id, amountController.text.toString())
            .then((value) {
          if (kDebugMode) {
            print("Success");
          }
        }).then((value) {
          Get.find<DepositHistoryController>()
              .getDepositHistorySearchData("", "", "", page: 1);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DepositHistoryScreen(
                        status: "true",
                      )),
              (route) => false);
          Get.dialog(AppPaymentSuccess());
        });
      }
    } on PlatformException catch (e, s) {
      if (kDebugMode) {
        print("Error initializing payment");
      }
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }

      if (kDebugMode) {
        print("Failed to init payment!");
      }
    }
  }

  String getRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random ranDom = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(ranDom.nextInt(chars.length))));
  }

  calculateMonnifyAmount(dynamic amount) {
    double conversionRate = double.parse(
        selectedGateway!.receivableCurrencies![0].conversionRate.toString());
    String formattedRate =
        conversionRate.toStringAsFixed(2); // Round to 2 decimal places

    double convertedAmount = double.parse(amount) * conversionRate;
    int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

    double amountWithPercentageCharge = totalCents *
        (double.parse(selectedGateway!.receivableCurrencies![0].percentageCharge
                .toString()) /
            100);
    double totalAmountWithFixCharge = amountWithPercentageCharge +
        double.parse(
            selectedGateway!.receivableCurrencies![0].fixedCharge.toString()) +
        totalCents;

    int totalAmountAsInt =
        totalAmountWithFixCharge.toInt(); // Convert to integer

    if (kDebugMode) {
      print("Formatted Rate: $formattedRate");
      print("Converted Amount: $convertedAmount");
      print("Total in Cents: $totalCents");
      print("Amount with Percentage Charge: $amountWithPercentageCharge");
      print("Amount with Fix Charge: $totalAmountWithFixCharge");
      print("Total Amount as Integer: $totalAmountAsInt");
    }

    return totalAmountAsInt.toDouble();
  }

  ///End Implementation**********/

  ///payUMoney Payment Integration
  ///Start Implementation*********

  ///End Implementation**********/

  ///paytm Payment Integration
  ///Start Implementation*********

  dynamic mid = "uAOkSk48844590235401", orderId = "10000", txnToken = "docss";
  String result = "tests";
  bool isStaging = false;
  bool isApiCallInProgress = false;
  String callbackUrl = "https://gobalshare.com/hyip/";
  bool restrictAppInvoke = false;
  bool enableAssist = true;

  Future<void> paytmPaymentRequest(dynamic planId, BuildContext context) async {
    if (txnToken.isEmpty) {
      return;
    }
    var sendMap = <String, dynamic>{
      "mid": midPaytm ?? mid,
      "orderId": orderId,
      "amount": calculatePaytmAmount(amountController.text).toString(),
      "txnToken": txnToken,
      "callbackUrl": callbackUrl,
      "isStaging": isStaging,
      "restrictAppInvoke": restrictAppInvoke,
      "enableAssist": enableAssist
    };
    if (kDebugMode) {
      print(sendMap);
    }
    try {
      var response = AllInOneSdk.startTransaction(
          midPaytm ?? mid,
          orderId,
          calculatePaytmAmount(amountController.text).toString(),
          txnToken,
          callbackUrl,
          isStaging,
          restrictAppInvoke,
          enableAssist);
      response.then((value) {
        if (kDebugMode) {
          print(value);
        }
        result = value.toString();
        Get.find<PaymentDoneController>()
            .paymentDoneRequest(trxId, selectedGateway!.id,
                calculatePaytmAmount(amountController.text.toString()))
            .then((value) {
          if (kDebugMode) {
            print("Success");
          }
        }).then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DepositHistoryScreen(
                        status: "true",
                      )),
              (route) => false);
          Get.dialog(AppPaymentSuccess());
        });
        update();
      }).catchError((onError) {
        if (onError is PlatformException) {
          result = "${onError.message} \n  ${onError.details}";
          update();
        } else {
          result = onError.toString();
          update();
        }
      });
    } catch (err) {
      result = err.toString();
    }
  }

  calculatePaytmAmount(dynamic amount) {
    double conversionRate = double.parse(
        selectedGateway!.receivableCurrencies![0].conversionRate.toString());
    String formattedRate =
        conversionRate.toStringAsFixed(2); // Round to 2 decimal places

    double convertedAmount = double.parse(amount) * conversionRate;
    int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

    double amountWithPercentageCharge = totalCents *
        (double.parse(selectedGateway!.receivableCurrencies![0].percentageCharge
                .toString()) /
            100);
    double totalAmountWithFixCharge = amountWithPercentageCharge +
        double.parse(
            selectedGateway!.receivableCurrencies![0].fixedCharge.toString()) +
        totalCents;

    int totalAmountAsInt =
        totalAmountWithFixCharge.toInt(); // Convert to integer

    if (kDebugMode) {
      print("Formatted Rate: $formattedRate");
      print("Converted Amount: $convertedAmount");
      print("Total in Cents: $totalCents");
      print("Amount with Percentage Charge: $amountWithPercentageCharge");
      print("Amount with Fix Charge: $totalAmountWithFixCharge");
      print("Total Amount as Integer: $totalAmountAsInt");
    }

    return totalAmountAsInt.toDouble();
  }

  ///End Implementation**********/

  /// PayStack Integration

  dynamic publicKeyTest =
      'pk_test_51196e34a819c61757bcd439fd5bfb0fe8a7b99a'; //pass in the public test key here
  final plugin = PaystackPlugin();

  void _showMessage(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate';
  }

  payStackPaymentRequest(BuildContext context, dynamic planId) async {
    var charge = Charge()
      ..amount = int.parse(calculatePayStackAmount(amountController.text))
      ..reference = _getReference()
      ..putCustomField('custom_id',
          '846gey6w') //to pass extra parameters to be retrieved on the response from Paystack
      ..email =
          '${Get.find<MyAccountController>().myAccountModel.message!.userEmail ?? "test@email.com"}';
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      Get.find<PaymentDoneController>()
          .paymentDoneRequest(
              trxId, selectedGateway!.id, amountController.text.toString())
          .then((value) {
        if (kDebugMode) {
          print("Success");
        }
      }).then((value) {
        Get.find<DepositHistoryController>()
            .getDepositHistorySearchData("", "", "", page: 1);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => DepositHistoryScreen(
                      status: "true",
                    )),
            (route) => false);
        Get.dialog(AppPaymentSuccess());
      });
    } else {
      _showMessage('Payment Failed!!!', context);
    }
  }

  calculatePayStackAmount(dynamic amount) {
    double conversionRate = double.parse(
        selectedGateway!.receivableCurrencies![0].conversionRate.toString());
    String formattedRate =
        conversionRate.toStringAsFixed(2); // Round to 2 decimal places

    double convertedAmount = double.parse(amount) * conversionRate;
    int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

    double amountWithPercentageCharge = totalCents *
        (double.parse(selectedGateway!.receivableCurrencies![0].percentageCharge
                .toString()) /
            100);
    double totalAmountWithFixCharge = amountWithPercentageCharge +
        double.parse(
            selectedGateway!.receivableCurrencies![0].fixedCharge.toString()) +
        totalCents;

    int totalAmountAsInt =
        totalAmountWithFixCharge.toInt(); // Convert to integer

    if (kDebugMode) {
      print("Formatted Rate: $formattedRate");
      print("Converted Amount: $convertedAmount");
      print("Total in Cents: $totalCents");
      print("Amount with Percentage Charge: $amountWithPercentageCharge");
      print("Amount with Fix Charge: $totalAmountWithFixCharge");
      print("Total Amount as Integer: $totalAmountAsInt");
    }

    return totalAmountAsInt.toString();
  }

  /// Paypal Integration
  /// Function to handle PayPal checkout
  void payPalPaymentRequest(dynamic planId, BuildContext context) {
    Get.to(PaypalCheckout(
      sandboxMode: true,
      clientId:
          "${clientIdPaypal ?? "Aa3Uh9sLX7mAZZSfo3OHkcE4Y9QZbaZep3qIsGC9bvXFeeLvnibTmVAcZSCYGAQ_h_BG0rq6KXucyuyr"}",
      secretKey:
          "${secretKeyPaypal ?? "EAkhsEdCVbeWQEGeQ4JWY2pVCyDISSU3-pXwbYnk1vzkPRy-PRsf7Pd9QId5_kxNxSfsaaSYP3hhICU6"}",
      returnURL: "success.snippetcoder.com",
      cancelURL: "cancel.snippetcoder.com",
      transactions: [
        {
          "amount": {
            "total": calculatePaypalAmount(amountController.text),
            "currency": "${selectedGateway!.receivableCurrencies![0].name}",
            "details": {
              "subtotal": calculatePaypalAmount(amountController.text),
              "shipping": '0',
              "shipping_discount": 0,
            },
          },
          "description": "Deposit Money",
        },
      ],
      note: "Contact us for any questions on your order.",
      onSuccess: (Map params) async {
        if (kDebugMode) {
          print("onSuccess: $params");
        }
        Get.find<PaymentDoneController>()
            .paymentDoneRequest(trxId, selectedGateway!.id,
                calculatePaypalAmount(amountController.text.toString()))
            .then((value) {
          if (kDebugMode) {
            print("Success");
          }
        }).then((value) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DepositHistoryScreen(
                        status: "true",
                      )),
              (route) => false);
          Get.dialog(AppPaymentSuccess());
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print("onError: $error");
        }
        Get.back(); // Navigate back using GetX
      },
      onCancel: () {
        if (kDebugMode) {
          print('cancelled:');
        }
      },
    ));
    update();
  }

  calculatePaypalAmount(dynamic amount) {
    double conversionRate = double.parse(
        selectedGateway!.receivableCurrencies![0].conversionRate.toString());
    String formattedRate =
        conversionRate.toStringAsFixed(2); // Round to 2 decimal places

    double convertedAmount = double.parse(amount) * conversionRate;
    int totalCents = (convertedAmount * 100).toInt(); // Convert to cents

    double amountWithPercentageCharge = totalCents *
        (double.parse(selectedGateway!.receivableCurrencies![0].percentageCharge
                .toString()) /
            100);
    double totalAmountWithFixCharge = amountWithPercentageCharge +
        double.parse(
            selectedGateway!.receivableCurrencies![0].fixedCharge.toString()) +
        totalCents;

    int totalAmountAsInt =
        totalAmountWithFixCharge.toInt(); // Convert to integer

    if (kDebugMode) {
      print("Formatted Rate: $formattedRate");
      print("Converted Amount: $convertedAmount");
      print("Total in Cents: $totalCents");
      print("Amount with Percentage Charge: $amountWithPercentageCharge");
      print("Amount with Fix Charge: $totalAmountWithFixCharge");
      print("Total Amount as Integer: $totalAmountAsInt");
    }

    return (totalAmountAsInt / 100).toString();
  }
}
