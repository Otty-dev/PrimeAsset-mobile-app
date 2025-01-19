import 'package:google_fonts/google_fonts.dart';
import 'package:clutch/controller/verification_controller.dart';
import 'package:clutch/utils/colors/app_colors.dart';
import 'package:clutch/view/screens/bottomnavbar/bottom_navbar.dart';
import 'package:clutch/view/screens/kyc/identify_form_screen.dart';
import 'package:clutch/view/widgets/app_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class IdentityVerificationScreen extends StatefulWidget {
  static const String routeName = "/identityVerificationScreen";
  const IdentityVerificationScreen(
      {super.key, this.isFromVerification = false});

  final bool? isFromVerification;

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final int kycIndex = 0;

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
                if (widget.isFromVerification == true) {
                  Get.offAll(BottomNavBar());
                } else {
                  Navigator.pop(context);
                }
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
            selectedLanguageStorage
                    .read("languageData")["Identity Verification"] ??
                "Identity Verification",
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
                    ? buildKycStatusWidget(
                        verificationController.submissionStatus.toString(),
                        verificationController)
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

  Widget buildKycStatusWidget(
      String status, VerificationController verificationController) {
    if (status.toLowerCase().contains("approved")) {
      return SizedBox(
        height: 600.h,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 150,
                child: Lottie.asset("assets/icon/verified.json")),
            Text(
              status,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 18.sp),
            ),
          ],
        ),
      );
    } else if (status.toLowerCase().contains("pending")) {
      return SizedBox(
        height: 600.h,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 250,
                height: 200,
                child: Lottie.asset("assets/icon/pending.json")),
            Text(
              status,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 18.sp),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding:
            EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h, bottom: 15.h),
        decoration: BoxDecoration(
          color: AppColors.getContainerBgDarkLight(),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: verificationController.verificationData.length,
          itemBuilder: (context, index) {
            final message = verificationController.verificationData[index];
            return ListTile(
              dense: false,
              onTap: () => Get.to(() => IdentityFormScreen(
                  kycId: message.id, kycIndex: index, kycTitle: message.name)),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                decoration: BoxDecoration(
                  color: AppColors.appPrimaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                width: 36.w,
                height: 36.h,
                padding: EdgeInsets.all(7.w),
                child:
                    Image.asset("assets/images/dark_identity_verification.png"),
              ),
              title: Text(
                message.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Image.asset(
                "assets/images/right_arrow.png", height: 12.h,
                width: 12.w,
                //color: AppColors.getTextDarkLight(),
              ),
            );
          },
        ),
      );
    }
  }
}
