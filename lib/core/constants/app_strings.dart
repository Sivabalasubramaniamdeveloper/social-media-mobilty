//	All user-visible strings and labels (e.g., "Login", "Welcome").
import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  static String get welcomeBack => 'welcome_back'.tr();
  static String get loginToYourAccount => 'login_to_your_account'.tr();
  static String get username => 'username'.tr();
  static String get siteName => 'siteName'.tr();

  // ======================
  //  API Call Methods
  // ======================
  static const String getAPI = "GET";
  static const String postAPI = "POST";

  // ======================
  //  Exception
  // ======================
  static const String failedToLoad = "Failed to load ";
}
