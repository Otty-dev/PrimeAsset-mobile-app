import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {}
  // void _updateConnectionStatus(ConnectivityResult connectivityResult) {
  //   if (connectivityResult == ConnectivityResult.none) {
  //     Get.dialog(
  //       const CustomDialog(),
  //       barrierDismissible: false,
  //     );
  //   } else {
  //     if (Get.isDialogOpen == true) {
  //       Get.back();
  //     }
  //   }
  // }
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // canPop: false,
      // onPopInvoked: (didPop) async {
      //   if (didPop) {
      //     return;
      //   }
      //   return;
      // },
      onWillPop: () async {
        return false; // Equivalent to `canPop: false`
      },
      child: AlertDialog(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/images/no_internet.json', // Replace with your image path
              height: 150.h,
              width: 150.w,
            ),
            Text(
              'No Internet!!! Please check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
