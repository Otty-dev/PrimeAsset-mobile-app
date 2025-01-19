import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/payout_controller.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/widgets/app_custom_button.dart';
import 'package:clutch/view/widgets/app_custom_dropdown.dart';
import 'package:clutch/view/widgets/app_drawer_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PayoutPreviewScreen extends StatefulWidget {
  static const String routeName = "/payout_preview_screen";
  dynamic gateway;
  dynamic amount;
  dynamic selectedType;
  dynamic fixedCharge;
  dynamic depositAmount;
  dynamic interestAmount;
  dynamic currencySymbol;
  dynamic percentageCharge;
  PayoutPreviewScreen(
      {super.key,
      this.gateway,
      this.amount,
      this.selectedType,
      this.fixedCharge,
      this.depositAmount,
      this.interestAmount,
      this.currencySymbol,
      this.percentageCharge});

  @override
  State<PayoutPreviewScreen> createState() => _PayoutPreviewScreenState();
}

class _PayoutPreviewScreenState extends State<PayoutPreviewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> fieldNames = [];
  List<String> fieldValues = [];

  dynamic selectedBankCode;
  double charge = 0.0;
  double totalPayable = 0.0;
  double availableBalance = 0.0;

  @override
  void dispose() {
    Get.delete<PayoutController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Perform your calculations here
    charge = double.parse(widget.fixedCharge) +
        (double.parse(widget.amount) *
            double.parse(widget.percentageCharge) /
            100);
    totalPayable = double.parse(widget.amount) +
        double.parse(widget.fixedCharge) +
        (double.parse(widget.amount) *
            double.parse(widget.percentageCharge) /
            100);

    if (widget.selectedType == "balance") {
      availableBalance = double.parse(widget.depositAmount) - totalPayable;
    } else {
      availableBalance = double.parse(widget.interestAmount) - totalPayable;
    }

    if (kDebugMode) {
      print(charge);
      print(totalPayable);
      print(availableBalance);
    }

    return GetBuilder<PayoutController>(builder: (payoutController) {
      return Scaffold(
        backgroundColor: AppColors.getBackgroundDarkLight(),
        appBar: AppBar(
          backgroundColor: AppColors.getAppBarBgDarkLight(),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: Image.asset(
                  "assets/images/arrow_back_btn.png",
                  height: 20.h,
                  width: 20.w,
                  color: AppColors.getTextDarkLight(),
                ),
              )),
          title: Text(
            "Payout Preview",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: AppColors.getTextDarkLight()),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Payment Details
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundDarkLight(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DottedBorder(
                          borderType: BorderType.RRect,
                          color: AppColors.appBlackColor30,
                          radius: Radius.circular(12),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: AppColors.getBackgroundDarkLight(),
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Payout by",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                      Text(
                                        "${widget.gateway.name}",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Requested Amount",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                      Text(
                                        "${widget.amount} ${widget.currencySymbol}",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Charge",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                      Text(
                                        "${charge}",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Payable",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                      Text(
                                        "${totalPayable.toStringAsFixed(2)} ${widget.currencySymbol}",
                                        style: GoogleFonts.niramit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Get.isDarkMode
                                                ? AppColors.appWhiteColor
                                                : AppColors.appBlackColor50),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  /// Bank Account Payout Logic
                  if (widget.gateway.name.toString().toLowerCase() ==
                      "bank transfer")
                    GetBuilder<PayoutController>(builder: (payoutController) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var fieldName in payoutController
                                  .selectedGateway!.parameters.entries)
                                buildFormField(fieldName.key, payoutController),
                              InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    payoutController.payoutConfirm(context);
                                  }
                                },
                                child: Container(
                                  height: 52.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      color: AppColors.appPrimaryColor),
                                  child: Center(
                                    child: Text(
                                      "${selectedLanguageStorage.read("languageData")["Next"] ?? "Next"}",
                                      style: GoogleFonts.niramit(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.sp,
                                          color: AppColors.appWhiteColor),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),

                  if ("${widget.gateway.name.toString().toLowerCase()}" != "bank transfer" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "flutterwave" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "razorpay" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "paystack" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "coinbase" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "perfect money" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "paypal" &&
                      "${widget.gateway.name.toString().toLowerCase()}" !=
                          "binance")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Container(
                        height: 500,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    final supportedCurrencies =
                                        controller.gatewaySupportedCurrencies[
                                            gateway.name];

                                    // Check if the gateway name is "Wire Transfer"
                                    if (gateway.name == widget.gateway.name)
                                    // if (gateway.name == "Bank Transfer" ||
                                    //     "${widget.data.name}" == "USDT" ||
                                    //     "${widget.data.name}" == "Semua Bank")
                                    {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          if (supportedCurrencies != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              height: 45.h,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              child: DropdownButton<String>(
                                                underline: const SizedBox(),
                                                isExpanded: true,
                                                items: supportedCurrencies,
                                                hint: Text(
                                                  "Select a currency",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                onChanged: (value) {
                                                  // Handle dropdown value change
                                                  setState(() {
                                                    controller
                                                            .selectedCurrency =
                                                        value;
                                                    controller
                                                            .selectedCurrencyController
                                                            .text =
                                                        value!; // Update the controller's value
                                                  });
                                                  if (kDebugMode) {
                                                    print(controller
                                                        .selectedCurrencyController
                                                        .text);
                                                  }
                                                },
                                                value:
                                                    controller.selectedCurrency,
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          if (gatewayFormFields != null)
                                            GetBuilder<PayoutController>(
                                                builder: (payoutController) {
                                              return Column(
                                                children: gatewayFormFields,
                                              );
                                            }),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    borderRadius: 32.00,
                                                    titleColor: Colors.white,
                                                    title: "Confirm Now",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      // payoutController.payoutConfirm(
                                                      //   context,
                                                      //   widget.selectedType,
                                                      //   widget.gateway.id,
                                                      //   totalPayable,
                                                      //   payoutController.fieldNames,
                                                      //   payoutController.fieldValues,
                                                      // );
                                                      // print(payoutController
                                                      //     .fieldNames);
                                                      // print(payoutController
                                                      //     .fieldValues);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          ),
                                          SizedBox(
                                            height: 40.h,
                                          )
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  /// FlutterWave Payout Logic
                  if ("${widget.gateway.name}" == "Flutterwave")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Transfer",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.getTextDarkLight(),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            DropdownButtonFormField2<String>(
                              isExpanded: true,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(14.w),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                  borderSide: BorderSide(
                                    color: AppColors.appPrimaryColor,
                                    width: 1.w,
                                  ),
                                ),
                                errorStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: AppColors.dangerColor,
                                        fontSize: 12.sp),
                                filled: true,
                                fillColor: AppColors.getTextFieldDarkLight(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return selectedLanguageStorage
                                              .read("languageData")[
                                          'Please select transfer.'] ??
                                      'Please select transfer.';
                                }
                                return null;
                              },
                              items: payoutController.flutterwaveBankList
                                  .toSet()
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: payoutController.selectedTransferName,
                              onChanged: (value) {
                                payoutController.selectedFlutterwaveBankName =
                                    null;
                                payoutController.selectedTransferName = null;
                                payoutController.selectedTransferName = value;
                                payoutController.getPayoutBankFormData(value);
                              },
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {}
                              },
                            ),
                            payoutController.isLoadingPayoutBank
                                ? Center(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 30.h),
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.appPrimaryColor),
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  )
                                : payoutController.messageBankData != null
                                    ? Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20.h),
                                            Text(
                                              "Select Bank",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            DropdownButtonFormField2<String>(
                                              isExpanded: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(14.w),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.w),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.w),
                                                  borderSide: BorderSide(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    width: 1.w,
                                                  ),
                                                ),
                                                errorStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: AppColors
                                                            .dangerColor,
                                                        fontSize: 12.sp),
                                                filled: true,
                                                fillColor: AppColors
                                                    .getTextFieldDarkLight(),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return selectedLanguageStorage
                                                              .read(
                                                                  "languageData")[
                                                          'Please select bank.'] ??
                                                      'Please select bank.';
                                                }
                                                return null;
                                              },
                                              items: payoutController
                                                  .flutterwaveBankTransferList
                                                  .map((bank) {
                                                return DropdownMenuItem<String>(
                                                  value: bank.name,
                                                  child: Text(
                                                    bank.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              value: payoutController
                                                  .selectedFlutterwaveBankName,
                                              onChanged: (value) {
                                                payoutController
                                                        .selectedFlutterwaveBankName =
                                                    value;
                                              },
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {}
                                              },
                                            ),
                                            SizedBox(height: 20.h),
                                            ...payoutController
                                                .inputFieldsData.keys
                                                .map((key) {
                                              TextEditingController controller =
                                                  payoutController
                                                      .textControllers[key]!;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(key
                                                      .replaceAll('_', ' ')
                                                      .toUpperCase()),
                                                  SizedBox(height: 5.h),
                                                  TextFormField(
                                                    controller: controller,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(14.w),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.w),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.w),
                                                        borderSide: BorderSide(
                                                          color: AppColors
                                                              .appPrimaryColor,
                                                          width: 1.w,
                                                        ),
                                                      ),
                                                      errorStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .dangerColor,
                                                              fontSize: 12.sp),
                                                      filled: true,
                                                      fillColor: AppColors
                                                          .getTextFieldDarkLight(),
                                                    ),
                                                  ),
                                                  SizedBox(height: 15.h),
                                                ],
                                              );
                                            }).toList(),
                                            InkWell(
                                              onTap: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  payoutController
                                                      .flutterwavePayoutConfirm(
                                                          context);
                                                }
                                              },
                                              child: Container(
                                                height: 52.h,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                    color: AppColors
                                                        .appPrimaryColor),
                                                child: Center(
                                                  child: Text(
                                                    "${selectedLanguageStorage.read("languageData")["Submit"] ?? "Submit"}",
                                                    style: GoogleFonts.niramit(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 20.sp,
                                                        color: AppColors
                                                            .appWhiteColor),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox()
                          ],
                        ),
                      ),
                    ),

                  /// PayStack Payout Logic
                  if ("${widget.gateway.name}" == "Paystack")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    // final supportedCurrencies = controller.gatewaySupportedCurrencies[gateway.name];

                                    // Check if the gateway name is "Paystack"
                                    if (gateway.name == "Paystack") {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //   "Select Currency",
                                          //   style: TextStyle(
                                          //     fontSize: 14.sp,
                                          //     fontWeight: FontWeight.w400,
                                          //     color: AppColors.getTextDarkLight(),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 6.h,
                                          // ),
                                          // if (supportedCurrencies != null)
                                          //   AppCustomDropDown(
                                          //     items: supportedCurrencies.map((item) => item.value!).toSet().toList(),
                                          //     onChanged: (value) {
                                          //       setState(() {
                                          //         controller.selectedCurrency = value;
                                          //         controller.selectedCurrencyController.text =
                                          //             value!; // Update the controller's value
                                          //         controller.getPayStackBankData(
                                          //             controller.selectedCurrencyController.text.toString());
                                          //       });
                                          //       if (kDebugMode) {
                                          //         print(controller.selectedCurrencyController.text);
                                          //       }
                                          //     },
                                          //     selectedValue: controller.selectedCurrency,
                                          //     hint: "Select a currency",
                                          //     fontSize: 14.sp,
                                          //     hintStyle: TextStyle(
                                          //       fontSize: 14.sp,
                                          //       fontWeight: FontWeight.w400,
                                          //       color: AppColors.getTextDarkLight(),
                                          //     ),
                                          //     selectedStyle: TextStyle(
                                          //       fontSize: 14.sp,
                                          //       fontWeight: FontWeight.w400,
                                          //       color: AppColors.getTextDarkLight(),
                                          //     ),
                                          //     decoration: BoxDecoration(
                                          //       borderRadius: BorderRadius.circular(10),
                                          //       color: AppColors.getTextFieldDarkLight(),
                                          //     ),
                                          //     dropdownDecoration: BoxDecoration(
                                          //       color: AppColors.getContainerBgDarkLight(),
                                          //       border:
                                          //           Border.all(color: Get.isDarkMode ? Colors.white10 : Colors.black12),
                                          //       borderRadius: BorderRadius.circular(5),
                                          //     ),
                                          //     width: double.infinity,
                                          //     height: 60.h,
                                          //   ),

                                          controller.isLoadingPayStack == false
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      "Select Bank",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6.h,
                                                    ),
                                                    if (controller
                                                            .messagePayStackBankData !=
                                                        null)
                                                      AppCustomDropDown(
                                                        items: controller
                                                            .messagePayStackBankData!
                                                            .data!
                                                            .map((bank) =>
                                                                bank.name!)
                                                            .toSet()
                                                            .toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            if (kDebugMode) {
                                                              print(
                                                                  "Selected bank code: $value");
                                                            }
                                                            // Update the selected bank in the controller
                                                            controller
                                                                    .selectedPayStackBank =
                                                                value!;
                                                          });
                                                        },
                                                        selectedValue: controller
                                                            .selectedPayStackBank,
                                                        hint: "Select a bank",
                                                        fontSize: 14.sp,
                                                        hintStyle: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .getTextDarkLight(),
                                                        ),
                                                        selectedStyle:
                                                            TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .getTextDarkLight(),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: AppColors
                                                              .getTextFieldDarkLight(),
                                                        ),
                                                        dropdownDecoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .getContainerBgDarkLight(),
                                                          border: Border.all(
                                                              color: Get.isDarkMode
                                                                  ? Colors
                                                                      .white10
                                                                  : Colors
                                                                      .black12),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        width: double.infinity,
                                                        height: 60.h,
                                                      ),
                                                  ],
                                                )
                                              : const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(25.0),
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                          if (gatewayFormFields != null)
                                            Column(
                                              children: gatewayFormFields,
                                            ),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    borderRadius: 32.00,
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    titleColor: Colors.white,
                                                    title: "Submit",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      payoutController
                                                          .paystackConfirm(
                                                              context);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          )
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  /// RazorPay Payout Logic
                  if ("${widget.gateway.name}" == "Razorpay")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  //physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    final supportedCurrencies =
                                        controller.gatewaySupportedCurrencies[
                                            gateway.name];

                                    // Check if the gateway name is "Razorpay"
                                    if (gateway.name == "Razorpay") {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          if (supportedCurrencies != null)
                                            AppCustomDropDown(
                                              items: supportedCurrencies
                                                  .map((item) => item.value!)
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  controller.selectedCurrency =
                                                      value;
                                                  controller
                                                          .selectedCurrencyController
                                                          .text =
                                                      value!; // Update the controller's value
                                                });
                                                if (kDebugMode) {
                                                  print(controller
                                                      .selectedCurrencyController
                                                      .text);
                                                }
                                              },
                                              selectedValue:
                                                  controller.selectedCurrency,
                                              hint: "Select a currency",
                                              fontSize: 14.sp,
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              selectedStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColors
                                                    .getTextFieldDarkLight(),
                                              ),
                                              dropdownDecoration: BoxDecoration(
                                                color: AppColors
                                                    .getContainerBgDarkLight(),
                                                border: Border.all(
                                                    color: Get.isDarkMode
                                                        ? Colors.white10
                                                        : Colors.black12),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              width: double.infinity,
                                              height: 60.h,
                                            ),
                                          const SizedBox(height: 12),
                                          if (gatewayFormFields != null)
                                            Column(
                                              children: gatewayFormFields,
                                            ),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    borderRadius: 32.00,
                                                    titleColor: Colors.white,
                                                    title: "Confirm Now",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      payoutController
                                                          .payoutConfirm(
                                                              context);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          ),
                                          SizedBox(height: 30.h),
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  /// Coinbase Payout Logic
                  if ("${widget.gateway.name}" == "Coinbase")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    final supportedCurrencies =
                                        controller.gatewaySupportedCurrencies[
                                            gateway.name];

                                    // Check if the gateway name is "Coinbase"
                                    if (gateway.name == "Coinbase") {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          if (supportedCurrencies != null)
                                            AppCustomDropDown(
                                              items: supportedCurrencies
                                                  .map((item) => item.value!)
                                                  .toSet()
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  controller.selectedCurrency =
                                                      value;
                                                  controller
                                                          .selectedCurrencyController
                                                          .text =
                                                      value!; // Update the controller's value
                                                });
                                                if (kDebugMode) {
                                                  print(controller
                                                      .selectedCurrencyController
                                                      .text);
                                                }
                                              },
                                              selectedValue:
                                                  controller.selectedCurrency,
                                              hint: "Select a currency",
                                              fontSize: 14.sp,
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              selectedStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColors
                                                    .getTextFieldDarkLight(),
                                              ),
                                              dropdownDecoration: BoxDecoration(
                                                color: AppColors
                                                    .getContainerBgDarkLight(),
                                                border: Border.all(
                                                    color: Get.isDarkMode
                                                        ? Colors.white10
                                                        : Colors.black12),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              width: double.infinity,
                                              height: 60.h,
                                            ),
                                          const SizedBox(height: 12),
                                          if (gatewayFormFields != null)
                                            Column(
                                              children: gatewayFormFields,
                                            ),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    borderRadius: 32.00,
                                                    titleColor: Colors.white,
                                                    title: "Confirm Now",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      payoutController
                                                          .payoutConfirm(
                                                              context);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          )
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  ///  Perfect Money Logic
                  if ("${widget.gateway.name}" == "Perfect Money")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    final supportedCurrencies =
                                        controller.gatewaySupportedCurrencies[
                                            gateway.name];

                                    // Check if the gateway name is "Perfect Money"
                                    if (gateway.name == "Perfect Money") {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          if (supportedCurrencies != null)
                                            AppCustomDropDown(
                                              items: supportedCurrencies
                                                  .map((item) => item.value!)
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  controller.selectedCurrency =
                                                      value;
                                                  controller
                                                          .selectedCurrencyController
                                                          .text =
                                                      value!; // Update the controller's value
                                                });
                                                if (kDebugMode) {
                                                  print(controller
                                                      .selectedCurrencyController
                                                      .text);
                                                }
                                              },
                                              selectedValue:
                                                  controller.selectedCurrency,
                                              hint: "Select a currency",
                                              fontSize: 14.sp,
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              selectedStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColors
                                                    .getTextFieldDarkLight(),
                                              ),
                                              dropdownDecoration: BoxDecoration(
                                                color: AppColors
                                                    .getContainerBgDarkLight(),
                                                border: Border.all(
                                                    color: Get.isDarkMode
                                                        ? Colors.white10
                                                        : Colors.black12),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              width: double.infinity,
                                              height: 60.h,
                                            ),
                                          const SizedBox(height: 8),
                                          if (gatewayFormFields != null)
                                            Column(
                                              children: gatewayFormFields,
                                            ),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    borderRadius: 32.00,
                                                    titleColor: Colors.white,
                                                    title: "Confirm Now",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      payoutController
                                                          .payoutConfirm(
                                                              context);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          )
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  /// Paypal Payout Logic
                  if ("${widget.gateway.name}" == "Paypal")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      controller.message!.gateways!.length,
                                  itemBuilder: (context, index) {
                                    final gateway =
                                        controller.message!.gateways![index];
                                    final gatewayFormFields = controller
                                        .gatewayFormFields[gateway.name];
                                    // final supportedCurrencies = controller.gatewaySupportedCurrencies[gateway.name];

                                    // Check if the gateway name is "Paypal"
                                    if (gateway.name == "Paypal") {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //   "Select Currency",
                                          //   style: GoogleFonts.niramit(
                                          //       color: AppColors.getTextDarkLight(),
                                          //       fontSize: 14.sp,
                                          //       fontWeight: FontWeight.w400),
                                          // ),
                                          // const SizedBox(height: 8),
                                          // if (supportedCurrencies != null)
                                          //   SizedBox(
                                          //     height: 60.h,
                                          //     child: AppCustomDropDown(
                                          //       items: supportedCurrencies.map((item) => item.value!).toList(),
                                          //       onChanged: (value) {
                                          //         setState(() {
                                          //           controller.selectedCurrency = value;
                                          //           controller.selectedCurrencyController.text =
                                          //               value!; // Update the controller's value
                                          //         });
                                          //         if (kDebugMode) {
                                          //           print(controller.selectedCurrencyController.text);
                                          //         }
                                          //       },
                                          //       selectedValue: controller.selectedCurrency,
                                          //       hint: "Select a currency",
                                          //       fontSize: 14.sp,
                                          //       hintStyle: TextStyle(
                                          //         fontSize: 14.sp,
                                          //         fontWeight: FontWeight.w400,
                                          //         color: AppColors.getTextDarkLight(),
                                          //       ),
                                          //       selectedStyle: TextStyle(
                                          //         fontSize: 14.sp,
                                          //         fontWeight: FontWeight.w400,
                                          //         color: AppColors.getTextDarkLight(),
                                          //       ),
                                          //       decoration: BoxDecoration(
                                          //         borderRadius: BorderRadius.circular(10),
                                          //         color: AppColors.getTextFieldDarkLight(),
                                          //       ),
                                          //       dropdownDecoration: BoxDecoration(
                                          //         color: AppColors.getContainerBgDarkLight(),
                                          //         border: Border.all(
                                          //             color: Get.isDarkMode ? Colors.white10 : Colors.black12),
                                          //         borderRadius: BorderRadius.circular(5),
                                          //       ),
                                          //       width: double.infinity,
                                          //       paddingLeft: 12,
                                          //     ),
                                          //   ),
                                          // const SizedBox(height: 16),
                                          Text(
                                            "Select Recipient Type",
                                            style: GoogleFonts.niramit(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  AppColors.getTextDarkLight(),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 60.h,
                                            child: AppCustomDropDown(
                                              items: paypalItem,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedPaypalItem =
                                                      newValue!;
                                                  if (kDebugMode) {
                                                    print(selectedPaypalItem);
                                                  }
                                                });
                                              },
                                              selectedValue: selectedPaypalItem,
                                              hint: "Select",
                                              fontSize: 14.sp,
                                              hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              selectedStyle: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .getTextDarkLight(),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColors
                                                    .getTextFieldDarkLight(),
                                              ),
                                              dropdownDecoration: BoxDecoration(
                                                color: AppColors
                                                    .getContainerBgDarkLight(),
                                                border: Border.all(
                                                    color: Get.isDarkMode
                                                        ? Colors.white10
                                                        : Colors.black12),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              width: double.infinity,
                                              paddingLeft: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (gatewayFormFields != null)
                                            Column(
                                              children: gatewayFormFields,
                                            ),
                                          SizedBox(height: 30.h),
                                          Center(
                                            child: payoutController
                                                        .isLoadingPayoutRequest ==
                                                    false
                                                ? AppCustomButton(
                                                    borderRadius: 32.00,
                                                    width: double.infinity,
                                                    height: 50.h,
                                                    titleColor: Colors.white,
                                                    title: "Confirm Now",
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    onTap: () {
                                                      payoutController
                                                          .payoutConfirm(
                                                              context);
                                                    },
                                                  )
                                                : CircularProgressIndicator(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                  ),
                                          )
                                        ],
                                      );
                                    } else {
                                      // Return an empty container for other gateways
                                      return Container();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                  /// Binance Payout Logic
                  if ("${widget.gateway.name}" == "Binance") ...{
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * .65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundDarkLight(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GetBuilder<PayoutController>(
                            builder: (controller) {
                              if (controller.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (controller.message != null) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        controller.message!.gateways!.length,
                                    itemBuilder: (context, index) {
                                      final gateway =
                                          controller.message!.gateways![index];
                                      final gatewayFormFields = controller
                                          .gatewayFormFields[gateway.name];
                                      dynamic supportedCurrencies =
                                          controller.gatewaySupportedCurrencies[
                                              gateway.name];

                                      // Check if the gateway name is "Wire Transfer"
                                      if (gateway.name == "Binance") {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            if (supportedCurrencies != null)
                                              SizedBox(
                                                height: 60.h,
                                                child: AppCustomDropDown(
                                                  items: (supportedCurrencies
                                                          as List<
                                                              DropdownMenuItem<
                                                                  dynamic>>)
                                                      .map(
                                                          (item) => item.value!)
                                                      .toSet()
                                                      .toList(),
                                                  onChanged: (value) {
                                                    // Handle dropdown value change
                                                    setState(() {
                                                      controller
                                                              .selectedCurrency =
                                                          value;
                                                      controller
                                                              .selectedCurrencyController
                                                              .text =
                                                          value!; // Update the controller's value
                                                    });
                                                    if (kDebugMode) {
                                                      print(controller
                                                          .selectedCurrencyController
                                                          .text);
                                                    }
                                                  },
                                                  selectedValue: controller
                                                      .selectedCurrency,
                                                  hint: "Select a currency",
                                                  fontSize: 14.sp,
                                                  hintStyle: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .getTextDarkLight(),
                                                  ),
                                                  selectedStyle: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors
                                                        .getTextDarkLight(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: AppColors
                                                        .getTextFieldDarkLight(),
                                                  ),
                                                  dropdownDecoration:
                                                      BoxDecoration(
                                                    color: AppColors
                                                        .getContainerBgDarkLight(),
                                                    border: Border.all(
                                                        color: Get.isDarkMode
                                                            ? Colors.white10
                                                            : Colors.black12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  width: double.infinity,
                                                  paddingLeft: 12,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            if (gatewayFormFields != null)
                                              Column(
                                                children: gatewayFormFields,
                                              ),
                                            SizedBox(height: 30.h),
                                            Center(
                                              child: payoutController
                                                          .isLoadingPayoutRequest ==
                                                      false
                                                  ? AppCustomButton(
                                                      width: double.infinity,
                                                      height: 50.h,
                                                      borderRadius: 32.00,
                                                      titleColor: Colors.white,
                                                      title: "Confirm Now",
                                                      color: AppColors
                                                          .appPrimaryColor,
                                                      onTap: () {
                                                        payoutController
                                                            .payoutConfirm(
                                                                context);
                                                      },
                                                    )
                                                  : CircularProgressIndicator(
                                                      color: AppColors
                                                          .appPrimaryColor,
                                                    ),
                                            )
                                          ],
                                        );
                                      } else {
                                        // Return an empty container for other gateways
                                        return Container();
                                      }
                                    },
                                  );
                                });
                              } else {
                                return const Center(
                                  child: Text('No data available.'),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  }
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  List<String> paypalItem = ["Email", "Phone", "Paypal ID"];

  dynamic selectedPaypalItem;

  Widget buildFormField(dynamic fieldName, PayoutController payoutController) {
    var field = payoutController.selectedGateway!.parameters[fieldName]
        as Map<String, dynamic>;
    TextEditingController controller =
        payoutController.textControllers[fieldName]!;

    if (field['type'] == 'file') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field['field_label']),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
                color: AppColors.getTextFieldDarkLight(),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: payoutController.pickedFiles[fieldName] == null
                      ? Image.asset(
                          "assets/images/drop.png",
                          width: 64.w,
                          height: 64.h,
                          fit: BoxFit.cover,
                          color: AppColors.appPrimaryColor,
                        )
                      : Image.file(
                          payoutController.pickedFiles[fieldName]!,
                          width: 120.w,
                          height: 90.h,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          payoutController.pickedFiles[fieldName] =
                              File(pickedFile.path);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(135.w, 35.h),
                      backgroundColor: AppColors.appPrimaryColor,
                      foregroundColor: Colors.white,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 14.sp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                    ),
                    child: const Text("Choose file")),
              ],
            ),
          ),
          SizedBox(height: 15.h),
        ],
      );
    } else if (field['type'] == 'date') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field['field_label']),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                final formattedDate =
                    DateFormat('MM/dd/yyyy').format(selectedDate);
                setState(() {
                  controller.text = formattedDate;
                });
              }
            },
            readOnly: true,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide(
                  color: AppColors.appPrimaryColor,
                  width: 1.w,
                ),
              ),
              errorStyle: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.dangerColor, fontSize: 12.sp),
              filled: true,
              fillColor: AppColors.getTextFieldDarkLight(),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field['field_label']),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            maxLines: field['type'] == 'textarea' ? 3 : 1,
            keyboardType: _getKeyboardType(field['type']),
            validator: (value) {
              if (field['validation'] == 'required' && value!.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide(
                  color: AppColors.appPrimaryColor,
                  width: 1.w,
                ),
              ),
              errorStyle: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.dangerColor, fontSize: 12.sp),
              filled: true,
              fillColor: AppColors.getTextFieldDarkLight(),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      );
    }
  }

  TextInputType _getKeyboardType(String fieldType) {
    switch (fieldType) {
      case 'text':
        return TextInputType.text;
      case 'number':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}
