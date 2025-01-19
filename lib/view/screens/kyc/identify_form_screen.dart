import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/verification_controller.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/widgets/app_drawer_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class IdentityFormScreen extends StatefulWidget {
  static const String routeName = "/identityFormScreen";
  const IdentityFormScreen(
      {super.key, this.kycId, required this.kycIndex, required this.kycTitle});

  final dynamic kycId;
  final int kycIndex;
  final String kycTitle;

  @override
  State<IdentityFormScreen> createState() => _IdentityFormScreenState();
}

class _IdentityFormScreenState extends State<IdentityFormScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerificationController>(
        builder: (verificationController) {
      return Scaffold(
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
            widget.kycTitle,
            style: GoogleFonts.publicSans(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              color: AppColors.getTextDarkLight(),
            ),
          ),
        ),
        body: Stack(
          children: [
            !verificationController.isScreenLoading
                ? verificationController.verificationData.isNotEmpty
                    ? buildKycStatusWidget(verificationController)
                    : Center(
                        child: Text(selectedLanguageStorage
                                .read("languageData")["No Data Found!"] ??
                            "No Data Found!"),
                      )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.appPrimaryColor),
                      strokeWidth: 2.0,
                    ),
                  ),
          ],
        ),
      );
    });
  }

  Widget buildKycStatusWidget(VerificationController verificationController) {
    return Container(
      margin: EdgeInsets.only(top: 20.h, left: 0.w, right: 0.w),
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.getContainerBgDarkLight(),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // for (var fieldName in verificationController.verificationData[widget.kycIndex].inputForm.entries)
                  //   buildFormField(fieldName.key, verificationController),
                  // verificationController.verificationData[widget.kycIndex].inputForm.entries.map((entry) {

                  // })

                  Container(
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: verificationController
                          .verificationData[widget.kycIndex].inputForm.entries
                          .map((entry) {
                        return buildFormField(
                            entry.key, verificationController);
                      }).toList(),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      verificationController.verificationSubmit(
                          widget.kycId, context);
                    },
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.appPrimaryColor,
                          borderRadius: BorderRadius.circular(32)),
                      child: Center(
                          child: verificationController.isLoading == false
                              ? Text(
                                  "Submit",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFormField(
      dynamic fieldName, VerificationController verificationController) {
    var field = verificationController
        .verificationData[widget.kycIndex].inputForm[fieldName];
    TextEditingController controller =
        verificationController.textControllers[fieldName]!;

    if (field!.type == 'file') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldLabel),
          SizedBox(height: 8.h),
          DottedBorder(
            dashPattern: const [8, 4],
            strokeWidth: 1.w,
            strokeCap: StrokeCap.round,
            borderType: BorderType.RRect,
            radius: Radius.circular(10.w),
            color: Colors.transparent,
            child: Container(
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
                    child: verificationController.pickedFiles[fieldName] == null
                        ? Image.asset(
                            "assets/images/drop.png",
                            color: AppColors.appPrimaryColor,
                            width: 64.w,
                            height: 64.h,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            verificationController.pickedFiles[fieldName]!,
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
                            verificationController.pickedFiles[fieldName] =
                                File(pickedFile.path);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(130.w, 35.h),
                        backgroundColor: AppColors.appPrimaryColor,
                        foregroundColor: AppColors.appWhiteColor,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 15.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                      ),
                      child: Text(selectedLanguageStorage
                              .read("languageData")["Choose file"] ??
                          "Choose file")),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      );
    } else if (field.type == 'date') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldLabel),
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
          SizedBox(height: 20.h),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.fieldLabel),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            maxLines: field.type == 'textarea' ? 3 : 1,
            keyboardType: _getKeyboardType(field.type),
            validator: (value) {
              if (field.validation == 'required' && value!.isEmpty) {
                return selectedLanguageStorage
                        .read("languageData")['This field is required'] ??
                    'This field is required';
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
          SizedBox(height: 20.h),
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
