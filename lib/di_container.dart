import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:clutch/controller/app_config_controller.dart';
import 'package:clutch/controller/app_steps_controller.dart';
import 'package:clutch/controller/auth_controller.dart';
import 'package:clutch/controller/badges_controller.dart';
import 'package:clutch/controller/bottom_navbar_controller.dart';
import 'package:clutch/controller/chnage_password_controller.dart';
import 'package:clutch/controller/create_ticket_controller.dart';
import 'package:clutch/controller/dashboard_controller.dart';
import 'package:clutch/controller/deposit_controller.dart';
import 'package:clutch/controller/deposit_history_controller.dart';
import 'package:clutch/controller/invest_history_controller.dart';
import 'package:clutch/controller/language_controller.dart';
import 'package:clutch/controller/my_account_controller.dart';
import 'package:clutch/controller/network_controller.dart';
import 'package:clutch/controller/payment_done_controller.dart';
import 'package:clutch/controller/payout_controller.dart';
import 'package:clutch/controller/payout_history_controller.dart';
import 'package:clutch/controller/plan_controller.dart';
import 'package:clutch/controller/pusher_config_controller.dart';
import 'package:clutch/controller/referral_bonus_controller.dart';
import 'package:clutch/controller/referral_controller.dart';
import 'package:clutch/controller/reply_ticket_controller.dart';
import 'package:clutch/controller/resend_code_controller.dart';
import 'package:clutch/controller/securion_authorizepay_controller.dart';
import 'package:clutch/controller/splash_controller.dart';
import 'package:clutch/controller/ticket_file_download_controller.dart';
import 'package:clutch/controller/ticket_list_controller.dart';
import 'package:clutch/controller/transaction_history_controller.dart';
import 'package:clutch/controller/transfer_controller.dart';
import 'package:clutch/controller/two_factor_controller.dart';
import 'package:clutch/controller/verification_controller.dart';
import 'package:clutch/controller/verify_required_controller.dart';
import 'package:clutch/controller/view_ticket_controller.dart';
import 'package:clutch/data/repository/app_steps_repo.dart';
import 'package:clutch/data/repository/auth_repo.dart';
import 'package:clutch/data/repository/badges_repo.dart';
import 'package:clutch/data/repository/change_password_repo.dart';
import 'package:clutch/data/repository/create_ticket_repo.dart';
import 'package:clutch/data/repository/dashboard_repo.dart';
import 'package:clutch/data/repository/deposit_history_repo.dart';
import 'package:clutch/data/repository/deposit_repo.dart';
import 'package:clutch/data/repository/invest_history_repo.dart';
import 'package:clutch/data/repository/language_repo.dart';
import 'package:clutch/data/repository/my_account_repo.dart';
import 'package:clutch/controller/notification_controller.dart';
import 'package:clutch/data/repository/payment_done_repo.dart';
import 'package:clutch/data/repository/payout_history_repo.dart';
import 'package:clutch/data/repository/payout_repo.dart';
import 'package:clutch/data/repository/plan_repo.dart';
import 'package:clutch/data/repository/pusher_config_repo.dart';
import 'package:clutch/data/repository/referral_bonus_repo.dart';
import 'package:clutch/data/repository/referral_repo.dart';
import 'package:clutch/data/repository/reply_ticket_repo.dart';
import 'package:clutch/data/repository/resend_code_repo.dart';
import 'package:clutch/data/repository/securion_authorizepay_repo.dart';
import 'package:clutch/data/repository/ticket_file_download_repo.dart';
import 'package:clutch/data/repository/ticket_list_repo.dart';
import 'package:clutch/data/repository/transaction_history_repo.dart';
import 'package:clutch/data/repository/transfer_repo.dart';
import 'package:clutch/data/repository/two_factor_repo.dart';
import 'package:clutch/data/repository/verification_repo.dart';
import 'package:clutch/data/repository/verify_required_repo.dart';
import 'package:clutch/data/repository/view_ticket_repo.dart';
import 'package:clutch/theme/theme_service.dart';
import 'package:clutch/utils/strings/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/locale_controller.dart';
import 'data/datasource/remote/dio/dio_client.dart';
import 'data/datasource/remote/dio/logging_interceptor.dart';
import 'data/repository/app_config_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Core
  sl.registerLazySingleton(() => DioClient(AppConstants.baseUri, sl(),
      loggingInterceptor: sl(), sharedPreferences: sl()));

  ///Repository
  sl.registerLazySingleton(
      () => AuthRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TransferRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => DashBoardRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => BadgesRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ReferralRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ReferralBonusRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => InvestHistoryRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TransactionHistoryRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => DepositHistoryRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => PayoutHistoryRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ViewTicketRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TicketListRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ReplyTicketRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => CreateTicketRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ChangePasswordRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TwoFaSecurityRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => PlanRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => MyAccountRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => VerificationRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => PayoutRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => PusherConfigRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => DepositRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => PaymentDoneRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(() =>
      SecurionPayAuthorizenetRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => LanguageRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => VerifyRequiredRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => AppConfigRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => AppStepsRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => TicketFileDownloadRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => ResendCodeRepo(dioClient: sl(), sharedPreferences: sl()));

  /// Controller
  Get.lazyPut(() => SplashController(), fenix: true);
  Get.lazyPut(() => AuthController(authRepo: sl(), dioClient: sl()),
      fenix: true);
  Get.lazyPut(() => BottomNavController(), fenix: true);
  Get.put<NetworkController>(NetworkController(), permanent: true);

  Get.lazyPut(() => TransferScreenController(transferRepo: sl()), fenix: true);
  Get.lazyPut(() => DashBoardController(dashBoardRepo: sl()), fenix: true);
  Get.lazyPut(() => BadgesController(badgesRepo: sl()), fenix: true);
  Get.lazyPut(() => ReferralController(referralRepo: sl()), fenix: true);
  Get.lazyPut(() => ReferralBonusController(referralBonusSearchRepo: sl()),
      fenix: true);
  Get.lazyPut(() => InvestHistoryController(investHistoryRepo: sl()),
      fenix: true);
  Get.lazyPut(() => TransactionHistoryController(transactionHistoryRepo: sl()),
      fenix: true);
  Get.lazyPut(() => DepositHistoryController(depositHistoryRepo: sl()),
      fenix: true);
  Get.lazyPut(() => PayoutHistoryController(payoutHistoryRepo: sl()),
      fenix: true);
  Get.lazyPut(() => ViewTicketController(viewTicketRepo: sl()), fenix: true);
  Get.lazyPut(() => TicketListController(ticketListRepo: sl()), fenix: true);
  Get.lazyPut(() => ReplyTicketController(replyTicketRepo: sl()), fenix: true);
  Get.lazyPut(() => CreateTicketController(createTicketRepo: sl()),
      fenix: true);
  Get.lazyPut(() => ChangePasswordController(changePasswordRepo: sl()),
      fenix: true);
  Get.lazyPut(() => TwoFaSecurityController(twoFaSecurityRepo: sl()),
      fenix: true);
  Get.lazyPut(() => TicketFileDownloadController(ticketFileDownloadRepo: sl()),
      fenix: true);
  Get.lazyPut(() => PlanController(planRepo: sl()), fenix: true);
  Get.lazyPut(() => MyAccountController(myAccountRepo: sl()), fenix: true);
  Get.lazyPut(() => VerificationController(verificationRepo: sl()),
      fenix: true);
  Get.lazyPut(() => PayoutController(payoutRepo: sl()), fenix: true);
  Get.lazyPut(() => PusherConfigController(pusherConfigRepo: sl()),
      fenix: true);
  Get.lazyPut(() => DepositController(depositScreenRepo: sl()), fenix: true);
  Get.lazyPut(() => PaymentDoneController(paymentDoneRepo: sl()), fenix: true);
  Get.lazyPut(
      () =>
          SecurionPayAuthorizenetController(securionPayAuthorizenetRepo: sl()),
      fenix: true);
  Get.lazyPut(() => LanguageController(languageRepo: sl()), fenix: true);
  Get.lazyPut(() => VerifyRequiredController(verifyRequiredRepo: sl()),
      fenix: true);
  Get.lazyPut(() => AppConfigController(appConfigRepo: sl()), fenix: true);
  Get.lazyPut(() => AppStepsController(appStepsRepo: sl()), fenix: true);
  Get.lazyPut(() => ResendCodeController(resendCodeRepo: sl()), fenix: true);
  Get.lazyPut(() => NotificationController(), fenix: true);
  Get.lazyPut(() => LocaleController(), fenix: true);
  Get.lazyPut(() => ThemeService(), fenix: true);

  /// External pocket lock
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => LoggingInterceptor());
}
