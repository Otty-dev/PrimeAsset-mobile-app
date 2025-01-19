import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/verification_controller.dart';
import 'package:clutch/data/model/response_model/kyc_model.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/screens/bottomnavbar/bottom_navbar.dart';

// ignore: must_be_immutable
class KycSubmissionListScreen extends StatefulWidget {
  dynamic status;
  static const String routeName = "/kycSubmissionListScreen";
  KycSubmissionListScreen({super.key, this.status});

  @override
  State<KycSubmissionListScreen> createState() =>
      _KycSubmissionListScreenState();
}

class _KycSubmissionListScreenState extends State<KycSubmissionListScreen> {
  final selectedLanguageStorage = GetStorage();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check the condition for 'widget.status'
        if (widget.status == "true") {
          // Navigate to BottomNavBar using GetX
          Get.offAllNamed(BottomNavBar.routeName);
        } else {
          // Use the Navigator to pop the current screen
          Navigator.pop(context);
        }
        // Return false to prevent the default back navigation
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          Get.find<VerificationController>().getKycSubmissionList();
        },
        child: GetBuilder<VerificationController>(
            builder: (verificationController) {
          return Scaffold(
              backgroundColor: AppColors.getBackgroundDarkLight(),
              appBar: AppBar(
                backgroundColor: AppColors.getAppBarBgDarkLight(),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (widget.status == "true") {
                            Get.offAllNamed(BottomNavBar.routeName);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset(
                          "assets/images/arrow_back_btn.png",
                          height: 20.h,
                          width: 20.w,
                          color: AppColors.getTextDarkLight(),
                        )),
                    Expanded(
                      child: Center(
                        child: Text(
                          "${selectedLanguageStorage.read("languageData")["Kyc Submissions"] ?? "Kyc Submissions"}",
                          style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                            color: AppColors.getTextDarkLight(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 8.h,
                    ),
                    GetBuilder<VerificationController>(
                      builder: (verificationController) {
                        // final historyItems = VerificationController.payoutHistorySearchItems;
                        if (verificationController.isScreenLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (verificationController.kycSubmissionList.isEmpty) {
                          return Center(child: Text('No data available'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              verificationController.kycSubmissionList.length,
                          itemBuilder: (context, index) {
                            final kycData =
                                verificationController.kycSubmissionList[index];
                            return InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      titlePadding: EdgeInsets.all(0.w),
                                      // backgroundColor: CustomColors.getContainerColor(),
                                      surfaceTintColor: Colors.transparent,
                                      content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    kycData.kycType,
                                                    style: GoogleFonts.publicSans(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20.sp,
                                                        color: AppColors
                                                            .getTextDarkLight()),
                                                  ),
                                                  SizedBox(height: 10),
                                                  ...kycData.kycInfo.values
                                                      .map((info) =>
                                                          buildFieldAsList(
                                                              info))
                                                      .toList(),
                                                  kycData.reason != null
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      5.h),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text("Reason"),
                                                              Text(kycData
                                                                  .reason),
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                            ],
                                          )),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 24.w, right: 24.w, bottom: 12.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Get.isDarkMode
                                        ? AppColors.appContainerBgColor
                                        : AppColors.appFillColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 16.w,
                                        right: 24.w,
                                        top: 12.h,
                                        bottom: 12.h),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 40.h,
                                          width: 40.w,
                                          decoration: BoxDecoration(
                                              color: checkStatusColor(
                                                  kycData.status),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(9.0),
                                            child: Image.asset(
                                              "${checkStatusIcon(kycData.status)}",
                                              height: 16.h,
                                              width: 16.w,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8.w,
                                        ),
                                        Expanded(
                                            flex: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${kycData.kycType}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14.sp,
                                                      color: AppColors
                                                          .getTextDarkLight(),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 6.h,
                                                  ),
                                                  Text(
                                                    "${kycData.createdAt}",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: AppColors
                                                          .appBlackColor50,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ));
        }),
      ),
    );
  }

  Widget buildFieldAsList(KycInfo info) {
    switch (info.type) {
      case 'text':
      case 'number':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(info.fieldLabel),
              Text(info.fieldValue),
            ],
          ),
        );
      case 'date':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(info.fieldLabel),
              Text(info.fieldValue),
            ],
          ),
        );
      case 'file':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.fieldLabel),
              SizedBox(height: 10),
              info.fieldValue.isNotEmpty
                  ? Image.network(info.fieldValue,
                      width: 100, height: 100, fit: BoxFit.cover)
                  : Text('No file uploaded'),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  checkStatusColor(dynamic status) {
    if (status == 1) {
      return AppColors.appDashBoardTransactionGreen;
    } else if (status == 0) {
      return AppColors.appDashBoardTransactionPending;
    } else {
      return AppColors.appDashBoardTransactionRed;
    }
  }

  checkStatusIcon(dynamic status) {
    if (status == 1) {
      return "assets/images/check.png";
    } else if (status == 0) {
      return "assets/images/pending_icon_history.png";
    } else {
      return "assets/images/reject.png";
    }
  }
}
