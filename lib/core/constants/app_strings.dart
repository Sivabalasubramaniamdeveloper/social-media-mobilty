//	All user-visible strings and labels (e.g., "Login", "Welcome").
import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  // ======================
  //  Common / Brand
  // ======================
  static String get appName => 'app_name'.tr();
  static String get mindAi => 'mind_ai'.tr();
  static String get poweredByLlms => 'powered_by_llms'.tr();
  static String get version => 'version'.tr();
  static String get yourAiProductivityHub => 'your_ai_productivity_hub'.tr();

  // ======================
  //  Auth – Login
  // ======================
  static String get welcomeBack => 'welcome_back'.tr();
  static String get loginToContinue => 'login_to_continue'.tr();
  static String get emailAddress => 'email_address'.tr();
  static String get enterYourEmail => 'enter_your_email'.tr();
  static String get password => 'password'.tr();
  static String get forgotPassword => 'forgot_password'.tr();
  static String get logIn => 'log_in'.tr();
  static String get or => 'or'.tr();
  static String get continueWithGoogle => 'continue_with_google'.tr();
  static String get dontHaveAccount => 'dont_have_account'.tr();
  static String get signUp => 'sign_up'.tr();

  // ======================
  //  Auth – Sign Up
  // ======================
  static String get createAccount => 'create_account'.tr();
  static String get joinFutureOfProductivity =>
      'join_future_of_productivity'.tr();
  static String get fullName => 'full_name'.tr();
  static String get enterYourFullName => 'enter_your_full_name'.tr();
  static String get confirmPassword => 'confirm_password'.tr();
  static String get confirm => 'confirm'.tr();
  static String get iAgreeToThe => 'i_agree_to_the'.tr();
  static String get termsOfService => 'terms_of_service'.tr();
  static String get createAccountButton => 'create_account_button'.tr();
  static String get orContinueWith => 'or_continue_with'.tr();
  static String get google => 'google'.tr();
  static String get apple => 'apple'.tr();
  static String get alreadyHaveAccount => 'already_have_account'.tr();

  // ======================
  //  Onboarding
  // ======================
  static String get skip => 'skip'.tr();
  static String get next => 'next'.tr();
  static String get resumeAndCareerAi => 'resume_and_career_ai'.tr();
  static String get resumeAnd => 'resume_and'.tr();
  static String get careerAi => 'career_ai'.tr();
  static String get resumeOnboardingDesc => 'resume_onboarding_desc'.tr();

  // ======================
  //  Form / Validation
  // ======================
  static String get fieldRequired => 'field_required'.tr();
  static String get invalidEmail => 'invalid_email'.tr();
  static String get passwordTooShort => 'password_too_short'.tr();
  static String get passwordsDoNotMatch => 'passwords_do_not_match'.tr();
  static String get pleaseAgreeTerms => 'please_agree_terms'.tr();
  static String get selectOption => 'select_option'.tr();
  static String get submit => 'submit'.tr();

  // ======================
  //  Legacy / existing
  // ======================
  static String get loginToYourAccount => 'login_to_your_account'.tr();
  static String get username => 'username'.tr();
  static String get siteName => 'siteName'.tr();

  // ======================
  // Auth – Verification & Success
  // ======================
  static String get verifyEmail => 'verify_email'.tr();
  static String get verifyYourEmail => 'verify_your_email'.tr();
  static String get weSentLinkTo => 'we_sent_link_to'.tr();
  static String get checkInboxDesc => 'check_inbox_desc'.tr();
  static String get iHaveVerified => 'i_have_verified'.tr();
  static String get resendEmail => 'resend_email'.tr();
  static String get didntGetEmail => 'didnt_get_email'.tr();
  static String get checkSpamFolder => 'check_spam_folder'.tr();
  static String get orContactSupport => 'or_contact_support'.tr();
  static String get backToSignUp => 'back_to_sign_up'.tr();
  static String get successTitle => 'success_title'.tr();
  static String get successProcessedDesc => 'success_processed_desc'.tr();
  static String get transactionId => 'transaction_id'.tr();
  static String get timestamp => 'timestamp'.tr();
  static String get backToHome => 'back_to_home'.tr();
  static String get viewTransactionDetails => 'view_transaction_details'.tr();

  // ======================
  // Home Dashboard
  // ======================
  static String get goodEveningUser => 'good_evening_user'.tr();
  static String get searchAiTools => 'search_ai_tools'.tr();
  static String get resumeAi => 'resume_ai'.tr();
  static String get resumeAiDesc => 'resume_ai_desc'.tr();
  static String get studyAi => 'study_ai'.tr();
  static String get studyAiDesc => 'study_ai_desc'.tr();
  static String get voiceTasks => 'voice_tasks'.tr();
  static String get voiceTasksDesc => 'voice_tasks_desc'.tr();
  static String get imageCaptions => 'image_captions'.tr();
  static String get imageCaptionsDesc => 'image_captions_desc'.tr();
  static String get developerAi => 'developer_ai'.tr();
  static String get developerAiDesc => 'developer_ai_desc'.tr();
  static String get docAnalyzer => 'doc_analyzer'.tr();
  static String get docAnalyzerDesc => 'doc_analyzer_desc'.tr();
  static String get recentActivity => 'recent_activity'.tr();
  static String get viewAll => 'view_all'.tr();
  static String get resumeUpdated => 'resume_updated'.tr();
  static String get resumeUpdatedDesc => 'resume_updated_desc'.tr();
  static String get time2mAgo => 'time_2m_ago'.tr();
  static String get apiIntegration => 'api_integration'.tr();
  static String get apiIntegrationDesc => 'api_integration_desc'.tr();
  static String get time45mAgo => 'time_45m_ago'.tr();
  static String get meetingTranscript => 'meeting_transcript'.tr();
  static String get meetingTranscriptDesc => 'meeting_transcript_desc'.tr();
  static String get time3hAgo => 'time_3h_ago'.tr();
  static String get navHome => 'nav_home'.tr();
  static String get navHistory => 'nav_history'.tr();
  static String get expense => 'expense'.tr();
  static String get navProfile => 'nav_profile'.tr();

  // ======================
  // Profile & Settings
  // ======================
  static String get profile => 'profile'.tr();
  static String get editProfile => 'edit_profile'.tr();
  static String get proPlan => 'pro_plan'.tr();
  static String get prompts => 'prompts'.tr();
  static String get timeSaved => 'time_saved'.tr();
  static String get streak => 'streak'.tr();
  static String get topModel => 'top_model'.tr();
  static String get top5PercentUsers => 'top_5_percent_users'.tr();
  static String get highEfficiency => 'high_efficiency'.tr();
  static String get aiCredits => 'ai_credits'.tr();
  static String get active => 'active'.tr();
  static String get creditsRenewOn => 'credits_renew_on'.tr();
  static String get monthlyLimitUsed => 'monthly_limit_used'.tr();
  static String get topUp => 'top_up'.tr();
  static String get upgradeToMindAiUltra => 'upgrade_to_mindai_ultra'.tr();
  static String get unlimitedPromptsEarlyAccess =>
      'unlimited_prompts_early_access'.tr();

  // Edit Profile Form
  static String get dateOfBirth => 'date_of_birth'.tr();
  static String get countryCode => 'country_code'.tr();
  static String get gender => 'gender'.tr();
  static String get language => 'language'.tr();
  static String get saveChanges => 'save_changes'.tr();
  static String get profileUpdatedSuccessfully =>
      'profile_updated_successfully'.tr();
  static String get failedToUpdateProfile => 'failed_to_update_profile'.tr();
  static String get male => 'male'.tr();
  static String get female => 'female'.tr();
  static String get other => 'other'.tr();
  static String get preferNotToSay => 'prefer_not_to_say'.tr();

  // Settings
  static String get settings => 'settings'.tr();
  static String get account => 'account'.tr();
  static String get preferences => 'preferences'.tr();
  static String get supportAndAbout => 'support_and_about'.tr();
  static String get subscriptionPlan => 'subscription_plan'.tr();
  static String get manageProPlanCredits => 'manage_pro_plan_credits'.tr();
  static String get pushNotifications => 'push_notifications'.tr();
  static String get aiAutoSummarize => 'ai_auto_summarize'.tr();
  static String get appLanguage => 'app_language'.tr();
  static String get hapticFeedback => 'haptic_feedback'.tr();
  static String get privacyPolicy => 'privacy_policy'.tr();
  static String get appVersionLabel => 'app_version_label'.tr();
  static String get logoutConfirmMessage => 'logout_confirm_message'.tr();
  static String get cancel => 'cancel'.tr();
  static String get logOut => 'log_out'.tr();

  // ======================
  // Weather & Daily Insights
  // ======================
  static String get weatherInsights => 'weather_insights'.tr();
  static String get weatherAiDesc => 'weather_ai_desc'.tr();
  static String get aiDailyRecommendation => 'ai_daily_recommendation'.tr();
  static String get weatherRecommendationBody =>
      'weather_recommendation_body'.tr();
  static String get precipitation => 'precipitation'.tr();
  static String get humidity => 'humidity'.tr();
  static String get windSpeed => 'wind_speed'.tr();
  static String get uvIndex => 'uv_index'.tr();
  static String get hourlyForecast => 'hourly_forecast'.tr();
  static String get weeklyForecast => 'weekly_forecast'.tr();
  static String get now => 'now'.tr();
  static String get sunny => 'sunny'.tr();
  static String get partlyCloudy => 'partly_cloudy'.tr();
  static String get rainy => 'rainy'.tr();
  static String get locationError => 'location_error'.tr();
  static String get locationDenied => 'location_denied'.tr();
  static String get locationDeniedForever => 'location_denied_forever'.tr();

  // ======================
  // Expense Tracker
  // ======================
  static String get expenseTracker => 'expense_tracker'.tr();
  static String get manageYourSpending => 'manage_your_spending'.tr();
  static String get totalBalance => 'total_balance'.tr();
  static String get income => 'income'.tr();
  static String get expenses => 'expenses'.tr();
  static String get spendingAnalysis => 'spending_analysis'.tr();
  static String get thisWeek => 'this_week'.tr();
  static String get thisMonth => 'this_month'.tr();
  static String get addNewExpense => 'add_new_expense'.tr();
  static String get trackIt => 'track_it'.tr();
  static String get recentExpenses => 'recent_expenses'.tr();
  static String get seeAll => 'see_all'.tr();
  static String get foodAndDrinks => 'food_and_drinks'.tr();
  static String get transportation => 'transportation'.tr();
  static String get shopping => 'shopping'.tr();
  static String get entertainment => 'entertainment'.tr();
  static String get starbucksCoffee => 'starbucks_coffee'.tr();
  static String get today1045Am => 'today_10_45_am'.tr();
  static String get uberRide => 'uber_ride'.tr();
  static String get yesterday620Pm => 'yesterday_6_20_pm'.tr();
  static String get appleStore => 'apple_store'.tr();
  static String get oct22215Pm => 'oct_22_2_15_pm'.tr();

  // ======================
  // Settings & Localization
  // ======================

  static String get editProfileSubtitle => 'edit_profile_subtitle'.tr();

  static String get proBadge => 'pro_badge'.tr();
  static String get selectLanguage => 'select_language'.tr();
  static String get englishLang => 'english_lang'.tr();
  static String get tamilLang => 'tamil_lang'.tr();

  // ======================
  // Budget & Dynamic Categories
  // ======================
  static String get budgetTracker => 'budget_tracker'.tr();
  static String get monthlyBudget => 'monthly_budget'.tr();
  static String get budgetProgress => 'budget_progress'.tr();
  static String get setBudget => 'set_budget'.tr();
  static String get noBudgetSet => 'no_budget_set'.tr();
  static String get addSavingsGoal => 'add_savings_goal'.tr();
  static String get savingsGoal => 'savings_goal'.tr();
  static String get optional => 'optional'.tr();
  static String get editSavingsGoal => 'edit_savings_goal'.tr();
  static String get targetAmount => 'target_amount'.tr();
  static String get savedSoFar => 'saved_so_far'.tr();
  static String get onTrack => 'on_track'.tr();
  static String get almostReachedLimit => 'almost_reached_limit'.tr();
  static String get budgetExceeded => 'budget_exceeded'.tr();
  static String get quickTrack => 'quick_track'.tr();
  static String get recentTransactions => 'recent_transactions'.tr();
  static String get allocatedLimit => 'allocated_limit'.tr();
  static String get remarks => 'Remarks'.tr();
  static String get incomeAndBudget => 'income_and_budget'.tr();
  static String get addIncome => 'add_income'.tr();
  static String get saveIncome => 'save_income'.tr();
  static String get recentGains => 'recent_gains'.tr();
  static String get noIncomeLogged => 'no_income_logged'.tr();
  static String get noTransactionsLogged => 'no_transactions_logged'.tr();
  static String get setOrEditBudget => 'set_or_edit_budget'.tr();
  static String get category => 'category'.tr();
  static String get allocatedLimitCurrency => 'allocated_limit_currency'.tr();
  static String get saveBudget => 'save_budget'.tr();
  static String get incomeSourceDetails => 'income_source_details'.tr();
  static String get additionalNotes => 'additional_notes'.tr();
  static String get enterValidAmount => 'enter_valid_amount'.tr();
  static String get enterValidBudget => 'enter_valid_budget'.tr();
  static String get otherIncome => 'other_income'.tr();
  static String get fromLastMonth => 'from_last_month'.tr();
  static String get used => 'used'.tr();
  static String get daysMon => 'days_mon'.tr();
  static String get daysTue => 'days_tue'.tr();
  static String get daysWed => 'days_wed'.tr();
  static String get daysThu => 'days_thu'.tr();
  static String get daysFri => 'days_fri'.tr();
  static String get daysSat => 'days_sat'.tr();
  static String get daysSun => 'days_sun'.tr();
  static String get sampleExpenseTitle => 'sample_expense_title'.tr();
  static String get sampleIncomeTitle => 'sample_income_title'.tr();
  static String get sampleBudgetAmount => 'sample_budget_amount'.tr();
  static String get sampleSavingsGoal => 'sample_savings_goal'.tr();
  static String get noBudgetsTapToCreate => 'no_budgets_tap_to_create'.tr();
  static String get titleLabel => 'title'.tr();
  static String get expenseSettings => 'expense_settings'.tr();
  static String get expenseSettingsDesc => 'expense_settings_desc'.tr();
  static String get allTransactions => 'all_transactions'.tr();
  static String get allBudgets => 'all_budgets'.tr();
  static String get filterByMonth => 'filter_by_month'.tr();
  static String get filterByYear => 'filter_by_year'.tr();
  static String get allMonths => 'all_months'.tr();
  static String get allYears => 'all_years'.tr();
  static String get all => 'all'.tr();
  static String get deleteTransaction => 'delete_transaction'.tr();
  static String get deleteConfirmMsg => 'delete_confirm_msg'.tr();
  static String get delete => 'delete'.tr();
  static String get transactionDeleted => 'transaction_deleted'.tr();
  static String get clearAllData => 'clear_all_data'.tr();
  static String get clearTransactions => 'clear_transactions'.tr();
  static String get resetBudgets => 'reset_budgets'.tr();
  static String get clearDataConfirm => 'clear_data_confirm'.tr();
  static String get clearTransactionsConfirm => 'clear_transactions_confirm'.tr();
  static String get dataClearedSuccess => 'data_cleared_success'.tr();
  static String get budgetAlertToggle => 'budget_alert_toggle'.tr();
  static String get budgetAlertDesc => 'budget_alert_desc'.tr();
  static String get manageBudgets => 'manage_budgets'.tr();
  static String get noTransactionsForPeriod => 'no_transactions_for_period'.tr();

  // Helper method to translate any category code or fallback to raw string
  static String getCategoryName(String key) {
    final trKey = key
        .toLowerCase()
        .replaceAll(' & ', '_and_')
        .replaceAll(' ', '_');
    final translated = trKey.tr();
    return translated == trKey ? key : translated;
  }

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
