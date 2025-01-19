import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/deposit_controller.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DepositPreviewScreen extends StatefulWidget {
  static const String routeName = "/depositPreviewScreen";
  dynamic gateway;
  dynamic amount;
  dynamic planId;
  dynamic charge;
  dynamic percentageCharge;
  dynamic conversionRate;
  dynamic currency;
  dynamic currencySymbol;
  dynamic conventionRate;
  DepositPreviewScreen(
      {super.key,
      this.gateway,
      this.amount,
      this.conversionRate,
      this.charge,
      this.currency,
      this.currencySymbol,
      this.conventionRate,
      this.percentageCharge,
      this.planId});

  @override
  State<DepositPreviewScreen> createState() => _DepositPreviewScreenState();
}

class _DepositPreviewScreenState extends State<DepositPreviewScreen> {
  final depositController = Get.put(DepositController());
  final selectedLanguageStorage = GetStorage();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (depositController) {
      return SelectionArea(
        child: Scaffold(
          backgroundColor: AppColors.getBackgroundDarkLight(),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.getAppBarBgDarkLight(),
            titleSpacing: 0,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 25.h,
                color: AppColors.getTextDarkLight(),
              ),
            ),
            automaticallyImplyLeading: false,
            title: Text(
              "${selectedLanguageStorage.read("languageData")["Deposit Preview"] ?? "Deposit Preview"}",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextDarkLight()),
            ),
          ),
          body: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.getBackgroundDarkLight(),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Please Follow The Instruction Below",
                              style: GoogleFonts.publicSans(
                                  color:
                                      AppColors.appDashBoardTransactionPending),
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Center(
                              child: Text(
                                "You have requested to deposit ${Get.find<DepositController>().amountController.text} USD , Please pay ${double.parse(widget.amount).toStringAsFixed(2)} for successful payment",
                                style: GoogleFonts.publicSans(
                                    color: AppColors.getTextDarkLight(),
                                    fontSize: 15.sp),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GetBuilder<DepositController>(
                      builder: (depositController) {
                        if (depositController.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (depositController.message != null) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (depositController.message != null)
                                  if (depositController.message!.gateways !=
                                      null)
                                    if (depositController
                                        .message!.gateways!.isNotEmpty)
                                      Text(depositController.manualPaymentNote
                                          .toString()),
                                SizedBox(height: 25.h),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var fieldName in depositController
                                          .selectedGateway!.parameters.entries)
                                        buildFormField(fieldName.key),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return Center(child: Text("No data available"));
                        }
                      },
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (kDebugMode) {
                            print(widget.gateway);
                            print(widget.amount);
                          }
                          if (_formKey.currentState!.validate()) {
                            depositController.manualPaymentRequest(
                                widget.gateway,
                                Get.find<DepositController>()
                                    .amountController
                                    .text,
                                context);
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: AppColors.appPrimaryColor,
                              borderRadius: BorderRadius.circular(32)),
                          child: Center(
                              child:
                                  depositController.isLoadingManualPay == false
                                      ? Text(
                                          "Pay Now",
                                          style: TextStyle(
                                              color: AppColors.appWhiteColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500),
                                        )
                                      : const CircularProgressIndicator(
                                          color: AppColors.appWhiteColor,
                                        )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget buildFormField(dynamic fieldName) {
    var field = depositController.selectedGateway!.parameters[fieldName]
        as Map<String, dynamic>;
    TextEditingController controller =
        depositController.textControllers[fieldName]!;

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
                  child: depositController.pickedFiles[fieldName] == null
                      ? Image.asset(
                          "assets/images/drop.png",
                          width: 64.w,
                          height: 64.h,
                          fit: BoxFit.cover,
                          color: AppColors.appPrimaryColor,
                        )
                      : Image.file(
                          depositController.pickedFiles[fieldName]!,
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
                          depositController.pickedFiles[fieldName] =
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
