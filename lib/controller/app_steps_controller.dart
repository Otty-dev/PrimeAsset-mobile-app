import 'package:get/get.dart';
import 'package:clutch/data/model/base_model/api_response.dart';
import 'package:clutch/data/model/response_model/app_steps_model.dart';
import 'package:clutch/data/repository/app_steps_repo.dart';

class AppStepsController extends GetxController {
  final AppStepsRepo appStepsRepo;

  AppStepsController({required this.appStepsRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  dynamic _status;

  dynamic get status => _status;
  List<Steps>? get message => _message;
  List<Steps>? _message;
  List<Steps> steps = [];

  AppStepsModel appStepsModel = AppStepsModel();

  Future<dynamic> getAppStepsData() async {
    _isLoading = true;
    update();
    ApiResponse apiResponse = await appStepsRepo.getAppStepsData();
    print(
        "app steps data 2 --------------------------> ${apiResponse.response}");

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      update();
      if (apiResponse.response!.data != null) {
        _message = null;
        update();
        appStepsModel = AppStepsModel.fromJson(apiResponse.response!.data!);
        steps = (apiResponse.response!.data!['message'] as List)
            .map((step) => Steps.fromJson(step))
            .toList();
        _message = appStepsModel.message;
        update();
      }
    } else {
      _isLoading = false;
      update();
    }
  }
}
