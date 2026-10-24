//	All user-visible strings and labels (e.g., "Login", "Welcome").
import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  // ======================
  //  Common / Brand
  // ======================
  static String get all => 'all'.tr();
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
  static String get forgotPasswordTitle => 'forgot_password_title'.tr();
  static String get forgotPasswordDescription =>
      'forgot_password_description'.tr();
  static String get sendResetLink => 'send_reset_link'.tr();
  static String get newPassword => 'new_password'.tr();
  static String get confirmNewPassword => 'confirm_new_password'.tr();
  static String get resetPassword => 'reset_password'.tr();
  static String get passwordResetSuccess => 'password_reset_success'.tr();
  static String get passwordResetEmailSent => 'password_reset_email_sent'.tr();
  static String get verificationEmailSent => 'verification_email_sent'.tr();
  static String get registrationCheckEmail => 'registration_check_email'.tr();
  static String get emailNotVerified => 'email_not_verified'.tr();
  static String get emailAlreadyRegistered => 'email_already_registered'.tr();
  static String get emailVerificationDisabled =>
      'email_verification_disabled'.tr();
  static String get emailConfirmedTitle => 'email_confirmed_title'.tr();
  static String get emailConfirmedDescription =>
      'email_confirmed_description'.tr();
  static String get resendVerificationFailed =>
      'resend_verification_failed'.tr();
  static String get passwordResetRequestFailed =>
      'password_reset_request_failed'.tr();
  static String get passwordUpdateFailed => 'password_update_failed'.tr();

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
  static String get aiVoiceAssistant => 'ai_voice_assistant'.tr();
  static String get listeningToVoice => 'listening_to_voice'.tr();
  static String get aiProcessingTask => 'ai_processing_task'.tr();
  static String get tapMicOrTypeCommand => 'tap_mic_or_type_command'.tr();
  static String get voiceTaskHint => 'voice_task_hint'.tr();
  static String get processTaskWithAi => 'process_task_with_ai'.tr();
  static String get aiAnalyzingTask => 'ai_analyzing_task'.tr();
  static String get saveAsTyped => 'save_as_typed'.tr();
  static String get voiceTaskChoiceHelp => 'voice_task_choice_help'.tr();
  static String get quickExamples => 'quick_examples'.tr();
  static String get taskSavePrompt => 'task_save_prompt'.tr();
  static String get taskSavedAsTyped => 'task_saved_as_typed'.tr();
  static String get taskSaveFailed => 'task_save_failed'.tr();
  static List<String> get voiceQuickSuggestions => [
    'voice_quick_meeting'.tr(),
    'voice_quick_doctor'.tr(),
    'voice_quick_budget'.tr(),
    'voice_quick_dinner'.tr(),
  ];
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
  static String get contactSupport => 'contact_support'.tr();
  static String get contactSupportSubtitle => 'contact_support_subtitle'.tr();
  static String get contactEmailSubject => 'contact_email_subject'.tr();
  static String get subscriptionPlan => 'subscription_plan'.tr();
  static String get managePlanCredits => 'manage_plan_credits'.tr();
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
  static String get allTime => 'all_time'.tr();
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
  static String get sampleAmount => 'sample_amount'.tr();
  static String get sampleIncomeTitle => 'sample_income_title'.tr();
  static String get sampleBudgetAmount => 'sample_budget_amount'.tr();
  static String get sampleSavingsGoal => 'sample_savings_goal'.tr();
  static String get noBudgetsTapToCreate => 'no_budgets_tap_to_create'.tr();
  static String get expenseSettings => 'expense_settings'.tr();
  static String get expenseSettingsDesc => 'expense_settings_desc'.tr();
  static String get firstIncomePromptTitle => 'first_income_prompt_title'.tr();
  static String get firstIncomePromptBody => 'first_income_prompt_body'.tr();
  static String get quickExpenseLogged => 'quick_expense_logged'.tr();
  static String get quickIncomeAdded => 'quick_income_added'.tr();
  static String get expenseSaved => 'expense_saved'.tr();
  static String get incomeSaved => 'income_saved'.tr();
  static String get validAmountRequired => 'valid_amount_required'.tr();
  static String get budgets => 'budgets'.tr();
  static String get budgetEditsMonthly => 'budget_edits_monthly'.tr();
  static String get cloudSyncIncluded => 'cloud_sync_included'.tr();
  static String get cloudSyncNotIncluded => 'cloud_sync_not_included'.tr();
  static String get currentPlan => 'current_plan'.tr();
  static String get basicPlan => 'basic_plan'.tr();
  static String get premiumPlan => 'premium_plan'.tr();
  static String get choosePlan => 'choose_plan'.tr();
  static String get selectPlan => 'select_plan'.tr();
  static String get planChangeUpdatesImmediately =>
      'plan_change_updates_immediately'.tr();
  static String get planChangedSuccessfully => 'plan_changed_successfully'.tr();
  static String get planChangeFailed => 'plan_change_failed'.tr();
  static String get subscriptionLoadFailed => 'subscription_load_failed'.tr();
  static String get noPlansAvailable => 'no_plans_available'.tr();
  static String get monthlyBudgetSettings => 'monthly_budget_settings'.tr();
  static String get autoRefreshMonthlyBudget =>
      'auto_refresh_monthly_budget'.tr();
  static String get autoRefreshBudgetEnabled =>
      'auto_refresh_budget_enabled'.tr();
  static String get manualBudgetModeEnabled =>
      'manual_budget_mode_enabled'.tr();
  static String get copyPreviousBudget => 'copy_previous_budget'.tr();
  static String get copyPreviousBudgetDescription =>
      'copy_previous_budget_description'.tr();
  static String get configureCurrentMonthLimits =>
      'configure_current_month_limits'.tr();
  static String get budgetAlertsDescription => 'budget_alerts_description'.tr();
  static String get downloadAndExport => 'download_and_export'.tr();
  static String get downloadExpensePdf => 'download_expense_pdf'.tr();
  static String get expensePdfDescription => 'expense_pdf_description'.tr();
  static String get downloadExpenseExcel => 'download_expense_excel'.tr();
  static String get expenseExcelDescription => 'expense_excel_description'.tr();
  static String get dataManagement => 'data_management'.tr();
  static String get deleteLoggedTransactions =>
      'delete_logged_transactions'.tr();
  static String get resetCategoryAllocations =>
      'reset_category_allocations'.tr();
  static String get clearAllFinancialData => 'clear_all_financial_data'.tr();
  static String get resetBudgetsConfirm => 'reset_budgets_confirm'.tr();
  static String get noPreviousBudgets => 'no_previous_budgets'.tr();
  static String get noBudgetsThisMonth => 'no_budgets_this_month'.tr();
  static String get budgetSetupDescription => 'budget_setup_description'.tr();
  static String get setMonthlyBudgetNow => 'set_monthly_budget_now'.tr();
  static String get firstBudgetTitle => 'first_budget_title'.tr();
  static String get firstBudgetDescription => 'first_budget_description'.tr();
  static String get setNow => 'set_now'.tr();
  static String get loggedTransactions => 'logged_transactions'.tr();
  static String get activeBudgets => 'active_budgets'.tr();
  static String get allLoggedRecords => 'all_logged_records'.tr();
  static String get planLimitReached => 'plan_limit_reached'.tr();
  static String get dismiss => 'dismiss'.tr();
  static String get viewPlans => 'view_plans'.tr();
  static String remainingImageQuota(int count) =>
      'remaining_image_quota'.tr(namedArgs: {'count': '$count'});
  static String imageQuotaReached(int limit, String period) =>
      'image_quota_reached'.tr(
        namedArgs: {'limit': '$limit', 'period': period},
      );
  static String get emotions => 'emotions'.tr();
  static String get coreEmotionsDescription => 'core_emotions_description'.tr();
  static String get updatedJustNow => 'updated_just_now'.tr();
  static String get retry => 'retry'.tr();
  static String get tryAgain => 'try_again'.tr();
  static String get mindAiSuggests => 'mind_ai_suggests'.tr();
  static String homeGreeting(String name) =>
      'home_greeting'.tr(namedArgs: {'name': name});
  static String get appTheme => 'app_theme'.tr();
  static String get chooseAppTheme => 'choose_app_theme'.tr();
  static String get themeSavedDescription => 'theme_saved_description'.tr();
  static String get englishLanguageCode => 'english_language_code'.tr();
  static String get tamilLanguageCode => 'tamil_language_code'.tr();
  static String get financialOverview => 'financial_overview'.tr();
  static String spentLabel(String amount) =>
      'spent_label'.tr(namedArgs: {'amount': amount});
  static String limitLabel(String amount) =>
      'limit_label'.tr(namedArgs: {'amount': amount});
  static String get export => 'export'.tr();
  static String get noTransactionsFound => 'no_transactions_found'.tr();
  static String noTransactionsFor(String period) =>
      'no_transactions_for'.tr(namedArgs: {'period': period});
  static String get addTransaction => 'add_transaction'.tr();
  static String get amountLabel => 'amount_label'.tr();
  static String failedToSave(String reason) =>
      'failed_to_save'.tr(namedArgs: {'reason': reason});
  static String get downloadExpenseReport => 'download_expense_report'.tr();
  static String exportFormatDescription(int count) =>
      'export_format_description'.tr(namedArgs: {'count': '$count'});
  static String get downloadPdfReport => 'download_pdf_report'.tr();
  static String get pdfReportDescription => 'pdf_report_description'.tr();
  static String get downloadExcelSheet => 'download_excel_sheet'.tr();
  static String get excelSheetDescription => 'excel_sheet_description'.tr();
  static String exportFailed(String format, String reason) =>
      'export_failed'.tr(namedArgs: {'format': format, 'reason': reason});
  static String exportPeriod(String period) =>
      'export_period'.tr(namedArgs: {'period': period});
  static String exportDate(String date) =>
      'export_date'.tr(namedArgs: {'date': date});
  static String exportPage(int page, int pages) =>
      'export_page'.tr(namedArgs: {'page': '$page', 'pages': '$pages'});
  static String get totalIncomeLabel => 'total_income_label'.tr();
  static String get totalExpensesLabel => 'total_expenses_label'.tr();
  static String get netBalanceLabel => 'net_balance_label'.tr();
  static String get totalLogsLabel => 'total_logs_label'.tr();
  static String get dateLabel => 'date_label'.tr();
  static String get titleLabel => 'title'.tr();
  static String get categoryLabel => 'category'.tr();
  static String get typeLabel => 'type_label'.tr();
  static String get amountColumn => 'amount_column'.tr();
  static String get notesLabel => 'notes_label'.tr();
  static String pdfSavedLocally(String file) =>
      'pdf_saved_locally'.tr(namedArgs: {'file': file});
  static String excelSavedLocally(String file) =>
      'excel_saved_locally'.tr(namedArgs: {'file': file});
  static String get exportNoTransactions => 'export_no_transactions'.tr();
  static String get excelSheetName => 'excel_sheet_name'.tr();
  static String get exportPdfFormat => 'export_pdf_format'.tr();
  static String get exportPdfFormatDescription =>
      'export_pdf_format_description'.tr();
  static String get exportExcelFormat => 'export_excel_format'.tr();
  static String get exportExcelFormatDescription =>
      'export_excel_format_description'.tr();
  static String get shareLabel => 'share'.tr();
  static String get mindAiExpenseExport => 'mind_ai_expense_export'.tr();
  static String expenseExportFileName(String date, String extension) =>
      'expense_export_file_name'.tr(
        namedArgs: {'date': date, 'extension': extension},
      );
  static String get sessionExpired => 'session_expired'.tr();
  static String get sessionExpiredDescription =>
      'session_expired_description'.tr();
  static String get continueLabel => 'continue'.tr();
  static String routeNotFound(String route) =>
      'route_not_found'.tr(namedArgs: {'route': route});
  static String get systemInitializing => 'system_initializing'.tr();
  static String get genericUnexpectedError => 'generic_unexpected_error'.tr();
  static String get studyTutorDescription => 'study_tutor_description'.tr();
  static String get voiceWorkflowDescription =>
      'voice_workflow_description'.tr();
  static String get budgetAlertsChannel => 'budget_alerts_channel'.tr();
  static String get budgetAlertsChannelDescription =>
      'budget_alerts_channel_description'.tr();
  static String get generalNotificationsChannel =>
      'general_notifications_channel'.tr();
  static String get generalNotificationsChannelDescription =>
      'general_notifications_channel_description'.tr();
  static String get highImportanceNotificationsChannel =>
      'high_importance_notifications_channel'.tr();
  static String get highImportanceNotificationsDescription =>
      'high_importance_notifications_description'.tr();
  static String get recurringNotificationsChannel =>
      'recurring_notifications_channel'.tr();
  static String get recurringNotificationsDescription =>
      'recurring_notifications_description'.tr();
  static String get backOnline => 'back_online'.tr();
  static String get loginFailed => 'login_failed'.tr();
  static String get registrationFailed => 'registration_failed'.tr();
  static String get priceDataAcrossStores => 'price_data_across_stores'.tr();
  static String get onboarding => 'onboarding'.tr();
  static String get studyAndPrefix => 'study_and_prefix'.tr();
  static String get learningAiTitle => 'learning_ai_title'.tr();
  static String get voiceAndPrefix => 'voice_and_prefix'.tr();
  static String get smartProductivityTitle => 'smart_productivity_title'.tr();
  static List<String> get weekDaysShort => [
    'days_mon'.tr(),
    'days_tue'.tr(),
    'days_wed'.tr(),
    'days_thu'.tr(),
    'days_fri'.tr(),
    'days_sat'.tr(),
    'days_sun'.tr(),
  ];
  static String copiedCategoryBudgets(int count) =>
      'copied_category_budgets'.tr(namedArgs: {'count': '$count'});
  static String budgetAlertTitle(String category) =>
      'budget_alert_title'.tr(namedArgs: {'category': category});
  static String budgetAlertUsed(int threshold, String category) =>
      'budget_alert_used'.tr(
        namedArgs: {'threshold': '$threshold', 'category': category},
      );
  static String budgetAlertExceeded(String spent, String limit) =>
      'budget_alert_exceeded'.tr(namedArgs: {'spent': spent, 'limit': limit});
  static String get allTransactions => 'all_transactions'.tr();
  static String get allBudgets => 'all_budgets'.tr();
  static String get filterByMonth => 'filter_by_month'.tr();
  static String get filterByYear => 'filter_by_year'.tr();
  static String get allMonths => 'all_months'.tr();
  static String get allYears => 'all_years'.tr();
  // static String get all => 'all'.tr();
  static String get deleteTransaction => 'delete_transaction'.tr();
  static String get deleteConfirmMsg => 'delete_confirm_msg'.tr();
  static String get delete => 'delete'.tr();
  static String get transactionDeleted => 'transaction_deleted'.tr();
  static String get clearAllData => 'clear_all_data'.tr();
  static String get clearTransactions => 'clear_transactions'.tr();
  static String get resetBudgets => 'reset_budgets'.tr();
  static String get clearDataConfirm => 'clear_data_confirm'.tr();
  static String get clearTransactionsConfirm =>
      'clear_transactions_confirm'.tr();
  static String get dataClearedSuccess => 'data_cleared_success'.tr();
  static String get budgetAlertToggle => 'budget_alert_toggle'.tr();
  static String get budgetAlertDesc => 'budget_alert_desc'.tr();
  static String get manageBudgets => 'manage_budgets'.tr();
  static String get noTransactionsForPeriod =>
      'no_transactions_for_period'.tr();

  // ======================
  // Product Scraper & Deals
  // ======================
  static String get productScraperTitle => 'product_scraper_title'.tr();
  static String get productScraperSubtitle => 'product_scraper_subtitle'.tr();
  static String get searchProductsHint => 'search_products_hint'.tr();
  static String get findDeals => 'find_deals'.tr();
  static String get comparePrices => 'compare_prices'.tr();
  static String get mindAiSuggestion => 'mind_ai_suggestion'.tr();
  static String get showAiDeal => 'show_ai_deal'.tr();
  static String get hideAiDeal => 'hide_ai_deal'.tr();
  static String get lowestPrice => 'lowest_price'.tr();
  static String get priceDifference => 'price_difference'.tr();
  static String get savings => 'savings'.tr();
  static String get allProducts => 'all_products'.tr();
  static String get viewProduct => 'view_product'.tr();
  static String get noProductsFound => 'no_products_found'.tr();
  static String get searchPrompt => 'search_prompt'.tr();

  // ======================
  // Price Comparison & Deals
  // ======================
  static String get comparePricesTitle => 'compare_prices_title'.tr();
  static String get comparePricesSubtitle => 'compare_prices_subtitle'.tr();
  static String get compareSearchHint => 'compare_search_hint'.tr();
  static String get compareButton => 'compare_button'.tr();
  static String get enterQueryPrompt => 'enter_query_prompt'.tr();
  static String get mindAiDealAnalysis => 'mindai_deal_analysis'.tr();
  static String get bestDealVerdict => 'best_deal_verdict'.tr();
  static String get savingsOpportunity => 'savings_opportunity'.tr();
  // static String get priceDifference => 'price_difference'.tr();
  static String get storesComparison => 'stores_comparison'.tr();
  static String get viewDeal => 'view_deal'.tr();
  static String get viewStore => 'view_store'.tr();
  static String get inStock => 'in_stock'.tr();
  static String get outOfStock => 'out_of_stock'.tr();
  static String get analyzingDeals => 'analyzing_deals'.tr();
  static String get aiRecommendationLabel => 'ai_recommendation_label'.tr();

  // ======================
  // Diary & Mood Tracker
  // ======================
  static String get personalDiary => 'personal_diary'.tr();
  static String get diarySubtitle => 'diary_subtitle'.tr();
  static String get dailyMotivation => 'daily_motivation'.tr();
  static String get noMemoryRecorded => 'no_memory_recorded'.tr();
  static String get viewEdit => 'view_edit'.tr();
  static String get write => 'write'.tr();
  static String get moodAndVibeAnalytics => 'mood_and_vibe_analytics'.tr();

  static String get syncToCloud => 'sync_to_cloud'.tr();
  static String syncSuccess(int count) =>
      'sync_success'.tr(namedArgs: {'count': count.toString()});
  static String get save => 'save'.tr();
  static String get aestheticTemplates => 'aesthetic_templates'.tr();
  static String get howAreYouFeeling => 'how_are_you_feeling'.tr();
  static String get headlineHint => 'headline_hint'.tr();
  static String get contentHint => 'content_hint'.tr();
  static String get addImages => 'add_images'.tr();
  static String get voiceNote => 'voice_note'.tr();
  static String get voiceRecordedMsg => 'voice_recorded_msg'.tr();
  static String defaultHeadline(String date) =>
      'default_headline'.tr(namedArgs: {'date': date});

  static String get moodHappy => 'mood_happy'.tr();
  static String get moodCalm => 'mood_calm'.tr();
  static String get moodNeutral => 'mood_neutral'.tr();
  static String get moodSad => 'mood_sad'.tr();
  static String get moodStressed => 'mood_stressed'.tr();

  // ======================
  // Diary & Reflections
  // ======================

  static String get myJournal => 'my_journal'.tr();
  static String get celebrateSmile => 'celebrate_smile'.tr();
  static String get startDayTitle => 'start_day_title'.tr();
  static String get startDaySub => 'start_day_sub'.tr();
  static String get quickJournal => 'quick_journal'.tr();

  static String get pauseReflect => 'pause_reflect'.tr();
  static String get pauseReflectSub => 'pause_reflect_sub'.tr();
  static String get setIntentions => 'set_intentions'.tr();
  static String get setIntentionsSub => 'set_intentions_sub'.tr();
  static String get emotionsTitle => 'emotions_title'.tr();
  static String get emotionsSubtitle => 'emotions_subtitle'.tr();
  static String get createNewJournal => 'create_new_journal'.tr();
  static String get chooseIcon => 'choose_icon'.tr();
  static String get addIcon => 'add_icon'.tr();
  static String get addPhotos => 'add_photos'.tr();
  static String get voiceMemos => 'voice_memos'.tr();
  static String get stickies => 'stickies'.tr();
  static String get growthAreas => 'growth_areas'.tr();
  static String get workFocus => 'work_focus'.tr();
  static String get workFocusSub => 'work_focus_sub'.tr();
  static String get showerThoughts => 'shower_thoughts'.tr();
  static String get tapCaptureThought => 'tap_capture_thought'.tr();
  static String get thisMonthsMood => 'this_months_mood'.tr();
  static String get todaysPrompt => 'todays_prompt'.tr();
  static String get defaultPromptText => 'default_prompt_text'.tr();
  static String get weeklyReflectionTitle => 'weekly_reflection_title'.tr();
  static String get monthlyReflectionTitle => 'monthly_reflection_title'.tr();
  static String get aiReflection => 'ai_reflection'.tr();
  static String get localInsights => 'local_insights'.tr();
  static String get askAiReflection => 'ask_ai_reflection'.tr();
  static String get reflectionDisclaimer => 'reflection_disclaimer'.tr();
  static String get bestMoments => 'best_moments'.tr();
  static String get difficultDays => 'difficult_days'.tr();

  static String get done => 'done'.tr();

  static String get journalContentHint => 'journal_content_hint'.tr();
  static String get moodGreat => 'mood_great'.tr();
  static String get moodGood => 'mood_good'.tr();
  static String get moodOkay => 'mood_okay'.tr();
  static String get moodLow => 'mood_low'.tr();
  static String get moodRough => 'mood_rough'.tr();
  static String get moodAnxious => 'mood_anxious'.tr();
  static String get moodMad => 'mood_mad'.tr();
  static String streakCount(int count) =>
      'streak_count'.tr(namedArgs: {'count': count.toString()});
  static String entriesCount(int count) =>
      'entries_count'.tr(namedArgs: {'count': count.toString()});
  static String photosCount(int count) =>
      'photos_count'.tr(namedArgs: {'count': count.toString()});
  static String audioCount(int count) =>
      'audio_count'.tr(namedArgs: {'count': count.toString()});

  static List<String> get dailyQuotes => [
    'quote_1'.tr(),
    'quote_2'.tr(),
    'quote_3'.tr(),
    'quote_4'.tr(),
    'quote_5'.tr(),
  ];

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
  //  OTT Video Player
  // ======================
  static String get videoQuality => 'video_quality'.tr();
  static String get qualityAuto => 'quality_auto'.tr();
  static String get qualityManual => 'quality_manual'.tr();
  static String get videoPlaybackFailed => 'video_playback_failed'.tr();
  static String get videoPlaybackFailedDesc =>
      'video_playback_failed_desc'.tr();
  static String get playbackSpeed => 'playback_speed'.tr();
  static String get normalSpeed => 'normal_speed'.tr();
  static String get secondsRewind => 'seconds_rewind'.tr();
  static String get secondsForward => 'seconds_forward'.tr();
  static String get fitToScreen => 'fit_to_screen'.tr();
  static String get originalAspectRatio => 'original_aspect_ratio'.tr();
  static String get watchNow => 'watch_now'.tr();
  static String get myList => 'my_list'.tr();

  // ======================
  //  Enhanced Subscription Strings
  // ======================
  static String get upgradeToUnlock => 'upgrade_to_unlock'.tr();
  static String get unlockUnlimitedPower => 'unlock_unlimited_power'.tr();
  static String get mostPopular => 'most_popular'.tr();
  static String get bestValue => 'best_value'.tr();
  static String get currentPlanBadge => 'current_plan_badge'.tr();
  static String get freeForever => 'free_forever'.tr();
  static String get perMonth => 'per_month'.tr();
  static String get upgradeNow => 'upgrade_now'.tr();
  static String get switchPlan => 'switch_plan'.tr();
  static String get activePlan => 'active_plan'.tr();
  static String get featuresIncluded => 'features_included'.tr();
  static String get dailyAiCreditsFeature => 'daily_ai_credits_feature'.tr();
  static String get smartScrapesFeature => 'smart_scrapes_feature'.tr();
  static String get budgetTrackingFeature => 'budget_tracking_feature'.tr();
  static String get monthlyBudgetEditsFeature =>
      'monthly_budget_edits_feature'.tr();
  static String get cloudBackupFeature => 'cloud_backup_feature'.tr();
  static String get diaryImagesFeature => 'diary_images_feature'.tr();

  // ======================
  //  Error & System Snackbars
  // ======================
  static String get serverErrorMessage => 'server_error'.tr();
  static String get badRequestErrorMessage => 'bad_request_error'.tr();
  static String get aiServiceErrorMessage => 'ai_service_error'.tr();
  static String get networkConnectionErrorMessage =>
      'network_connection_error'.tr();
  static String get sessionExpiredMessage => 'session_expired'.tr();
  static String get accessDeniedMessage => 'access_denied'.tr();
  static String get rateLimitErrorMessage => 'rate_limit_error'.tr();
  static String get emailSentSuccess => 'email_sent_success'.tr();
  static String get somethingWentWrong => 'something_went_wrong'.tr();
  static String get itemCopied => 'item_copied'.tr();
  static String get itemDeleted => 'item_deleted'.tr();
  static String get itemSaved => 'item_saved'.tr();

  // ======================
  //  News Screen
  // ======================
  static String get localCityNews => 'local_city_news'.tr();
  static String get webScrapingNews => 'web_scraping_news'.tr();
  static String get noNewsFound => 'no_news_found'.tr();
  static String get readFullStory => 'read_full_story'.tr();
  static String get shareArticle => 'share_article'.tr();
  static String get shareViaEmail => 'share_via_email'.tr();
  static String get topHeadlines => 'top_headlines'.tr();
  static String get loadNews => 'load_news'.tr();
  static String get recent => 'recent'.tr();
  static String get newsArticleLinkError => 'news_article_link_error'.tr();

  // ======================
  //  OTT Screen
  // ======================
  static String get forYou => 'for_you'.tr();
  static String get popularRightNow => 'popular_right_now'.tr();
  static String get featured => 'featured'.tr();
  static String get nowStreaming => 'now_streaming'.tr();
  static String get original => 'original'.tr();
  static String get ottLoadError => 'ott_load_error'.tr();
  static String get ottRetrySub => 'ott_retry_sub'.tr();
  static String get ottEmptyTitle => 'ott_empty_title'.tr();
  static String get ottEmptySub => 'ott_empty_sub'.tr();
  // static String get developerAi => 'developer_ai'.tr();

  // ======================
  //  Tasks Screen
  // ======================
  static String get myTasks => 'my_tasks'.tr();
  static String get createTask => 'create_task'.tr();
  static String get updateTask => 'update_task'.tr();
  static String get taskTitle => 'task_title'.tr();
  static String get taskDescription => 'task_description'.tr();
  static String get taskDueDate => 'task_due_date'.tr();
  static String get taskPriority => 'task_priority'.tr();
  static String get priorityLow => 'priority_low'.tr();
  static String get priorityMedium => 'priority_medium'.tr();
  static String get priorityHigh => 'priority_high'.tr();
  static String get taskCategory => 'task_category'.tr();
  static String get taskCompleted => 'task_completed'.tr();
  static String get taskPending => 'task_pending'.tr();
  static String get taskSavedSuccess => 'task_saved_success'.tr();
  static String get taskDeleteConfirm => 'task_delete_confirm'.tr();
  static String get deleteTask => 'delete_task'.tr();
  static String get voiceAssistant => 'voice_assistant'.tr();
  static String get speakNow => 'speak_now'.tr();
  static String get listening => 'listening'.tr();
  static String get tapToSpeak => 'tap_to_speak'.tr();
  static String get noTasksFound => 'no_tasks_found'.tr();

  // ======================
  //  Vault Screen
  // ======================
  static String get secureVault => 'secure_vault'.tr();
  static String get vaultSubtitle => 'vault_subtitle'.tr();
  static String get passwords => 'passwords'.tr();
  static String get documents => 'documents'.tr();
  static String get photos => 'photos'.tr();
  static String get notes => 'notes'.tr();
  static String get addItem => 'add_item'.tr();
  static String get addPassword => 'add_password'.tr();
  static String get addDocument => 'add_document'.tr();
  static String get addPhoto => 'add_photo'.tr();
  static String get vaultEmpty => 'vault_empty'.tr();
  static String get vaultEmptySub => 'vault_empty_sub'.tr();
  static String get deleteItemConfirm => 'delete_item_confirm'.tr();
  static String get copyPassword => 'copy_password'.tr();
  static String get revealPassword => 'reveal_password'.tr();
  static String get itemSavedVault => 'item_saved_vault'.tr();

  // ======================
  //  Scraper & Comparison
  // ======================
  static String get productScraper => 'product_scraper'.tr();
  // static String get searchProductsHint => 'search_products_hint'.tr();
  static String get comparePricesTag => 'compare_prices_tag'.tr();
  static String get bestDealTag => 'best_deal_tag'.tr();
  static String get allStores => 'all_stores'.tr();
  static String get amazonStore => 'amazon_store'.tr();
  static String get flipkartStore => 'flipkart_store'.tr();
  static String get meeshoStore => 'meesho_store'.tr();
  // static String get priceDifference => 'price_difference'.tr();
  // static String get savings => 'savings'.tr();
  // static String get noProductsFound => 'no_products_found'.tr();
  // static String get viewDeal => 'view_deal'.tr();
  static String get cheaperOn => 'cheaper_on'.tr();
  static String get searchingStores => 'searching_stores'.tr();

  // ======================
  //  Email Helper Screen
  // ======================
  static String get aiEmailHelper => 'ai_email_helper'.tr();
  static String get composeEmail => 'compose_email'.tr();
  static String get emailSubject => 'email_subject'.tr();
  static String get emailBody => 'email_body'.tr();
  static String get recipientEmail => 'recipient_email'.tr();
  static String get generateDraft => 'generate_draft'.tr();
  static String get sendEmail => 'send_email'.tr();
  static String get emailSent => 'email_sent'.tr();
  static String get emailTemplates => 'email_templates'.tr();
  static String get toneProfessional => 'tone_professional'.tr();
  static String get toneCasual => 'tone_casual'.tr();
  static String get toneFriendly => 'tone_friendly'.tr();
  static String get toneUrgent => 'tone_urgent'.tr();
  static String get emailAnalytics => 'email_analytics'.tr();

  // ======================
  //  API Keys Screen
  // ======================
  static String get apiKeysTitle => 'api_keys_title'.tr();
  static String get apiKeysSubtitle => 'api_keys_subtitle'.tr();
  static String get addApiKey => 'add_api_key'.tr();
  static String get provider => 'provider'.tr();
  static String get enterApiKey => 'enter_api_key'.tr();
  static String get keySavedSecurely => 'key_saved_securely'.tr();
  static String get deleteKeyConfirm => 'delete_key_confirm'.tr();
  static String get activeKey => 'active_key'.tr();
  static String get noApiKeys => 'no_api_keys'.tr();

  // ======================
  //  Diary Screen
  // ======================
  static String get writeEntry => 'write_entry'.tr();
  static String get editEntry => 'edit_entry'.tr();
  static String get deleteEntry => 'delete_entry'.tr();
  static String get moodHype => 'mood_hype'.tr();
  static String get shareMood => 'share_mood'.tr();
  static String get entrySaved => 'entry_saved'.tr();
  static String get searchJournal => 'search_journal'.tr();
  static String get moodPosterShared => 'mood_poster_shared'.tr();
  static String get moodPosterShareFailed => 'mood_poster_share_failed'.tr();
  static String get shareMoodVibe => 'share_mood_vibe'.tr();

  // ======================
  //  Email Additional Strings
  // ======================
  static String get saveEmail => 'save_email'.tr();
  static String get saveGeneratedEmail => 'save_generated_email'.tr();
  static String get labelNameHint => 'label_name_hint'.tr();
  static String get enterLabelName => 'enter_label_name'.tr();
  static String get intendedRecipient => 'intended_recipient'.tr();
  static String get emailSavedSuccess => 'email_saved_success'.tr();
  static String get emailSpamNotice => 'email_spam_notice'.tr();
  static String get chooseTone => 'choose_tone'.tr();
  static String get emailPurposeInstructions =>
      'email_purpose_instructions'.tr();

  // ======================
  //  Voice Assistant Strings
  // ======================
  static String get voiceMicNotAvailable => 'voice_mic_not_available'.tr();
  static String get listeningSpeakTask => 'listening_speak_task'.tr();
  static String get pleaseEnterTask => 'please_enter_task'.tr();

  // ======================
  //  Streams / OTT & News Providers
  // ======================
  static String get mineAiStreams => 'mine_ai_streams'.tr();
  static String get mineAiStreamsDesc => 'mine_ai_streams_desc'.tr();
  static String get providerAll => 'provider_all'.tr();
  static String get providerToi => 'provider_toi'.tr();
  static String get providerTheHindu => 'provider_the_hindu'.tr();
  static String get providerOther => 'provider_other'.tr();
  static String get breakingNews => 'breaking_news'.tr();
  static String get filterBySource => 'filter_by_source'.tr();
  static String get selectedCityOnly => 'selected_city_only'.tr();
  static String get edit => 'edit'.tr();
  static String get phoneNumber => 'phone_number'.tr();
  static String get notSpecified => 'not_specified'.tr();
  static String get timezone => 'timezone'.tr();
  static String get country => 'country'.tr();
  static String get close => 'close'.tr();
  static String get back => 'back'.tr();
  static String get directCompose => 'direct_compose'.tr();
  static String get composeWithoutAi => 'compose_without_ai'.tr();
  static String get customCategories => 'custom_categories'.tr();
  static String get customCategoriesDesc => 'custom_categories_desc'.tr();
  static String get editTransaction => 'edit_transaction'.tr();
  static String get updateTransaction => 'update_transaction'.tr();
  static String get deleteTaskConfirm => 'delete_task_confirm'.tr();
  static String get lockedFeaturePro => 'locked_feature_pro'.tr();
  static String get customCategoryProDesc => 'custom_category_pro_desc'.tr();
  static String get addCategory => 'add_category'.tr();
  static String get categoryName => 'category_name'.tr();
  static String get selectIcon => 'select_icon'.tr();
  static String get exitToStreams => 'exit_to_streams'.tr();
  static String get transactionUpdated => 'transaction_updated'.tr();
  static String get directEmailSent => 'direct_email_sent'.tr();

  // Support & Ticketing
  static String get supportTickets => 'support_tickets'.tr();
  static String get newTicket => 'new_ticket'.tr();
  static String get searchTickets => 'search_tickets'.tr();
  static String get allTickets => 'all_tickets'.tr();
  static String get ticketStatusOpen => 'ticket_status_open'.tr();
  static String get ticketStatusInProgress => 'ticket_status_in_progress'.tr();
  static String get ticketStatusResolved => 'ticket_status_resolved'.tr();
  static String get noTicketsFound => 'no_tickets_found'.tr();
  static String get noTicketsFoundDesc => 'no_tickets_found_desc'.tr();
  static String get reportIssue => 'report_issue'.tr();
  static String get selectModule => 'select_module'.tr();
  static String get issueCategory => 'issue_category'.tr();
  static String get categoryBug => 'category_bug'.tr();
  static String get categoryFeatureRequest => 'category_feature_request'.tr();
  static String get categoryPerformance => 'category_performance'.tr();
  static String get categoryOther => 'category_other'.tr();
  static String get priorityLevel => 'priority_level'.tr();
  static String get subjectTitle => 'subject_title'.tr();
  static String get subjectHint => 'subject_hint'.tr();
  static String get issueDescription => 'issue_description'.tr();
  static String get issueDescriptionHint => 'issue_description_hint'.tr();
  static String get adminTicketNotice => 'admin_ticket_notice'.tr();
  static String get submitTicket => 'submit_ticket'.tr();
  static String get ticketStatus => 'ticket_status'.tr();
  static String get stepSubmitted => 'step_submitted'.tr();
  static String get stepInProgress => 'step_in_progress'.tr();
  static String get stepResolved => 'step_resolved'.tr();
  static String get adminTeamResponse => 'admin_team_response'.tr();
  static String get adminReviewingNotice => 'admin_reviewing_notice'.tr();
  static String get subjectRequired => 'subject_required'.tr();
  static String get descriptionRequired => 'description_required'.tr();
  static String get ticketSubmittedSuccess => 'ticket_submitted_success'.tr();
  static String get failedToSubmitTicket => 'failed_to_submit_ticket'.tr();
  static String get trackIssuesAndRequests => 'track_issues_and_requests'.tr();

  // Custom Categories
  static String get customCategoriesUnlocked =>
      'custom_categories_unlocked'.tr();
  static String get allCategories => 'all_categories'.tr();
  static String get noCustomCategoriesYet => 'no_custom_categories_yet'.tr();
  static String get noCustomCategoriesDesc => 'no_custom_categories_desc'.tr();
  static String get customExpenseCategory => 'custom_expense_category'.tr();
  static String get customIncomeSource => 'custom_income_source'.tr();
  static String get customCategoryCreated => 'custom_category_created'.tr();
  static String get enterCategoryName => 'enter_category_name'.tr();

  // General & Vault & Email
  static String get privatePhotoSaved => 'private_photo_saved'.tr();
  static String get documentStoredVault => 'document_stored_vault'.tr();
  static String get passwordCopied => 'password_copied'.tr();
  static String get itemDeletedVault => 'item_deleted_vault'.tr();
  static String get imageMissingVault => 'image_missing_vault'.tr();
  static String get fileNotExist => 'file_not_exist'.tr();
  static String get apiKeyDeleted => 'api_key_deleted'.tr();
  static String get enterKeyValue => 'enter_key_value'.tr();
  static String get deleteKeyTitle => 'delete_key_title'.tr();
  static String get deleteSavedEmailConfirm =>
      'delete_saved_email_confirm'.tr();
  static String get enterSubjectOrMessage => 'enter_subject_or_message'.tr();
  static String get enterEmailContentToSave =>
      'enter_email_content_to_save'.tr();
  static String get describeEmailPurpose => 'describe_email_purpose'.tr();
  static String get upgrade => 'upgrade'.tr();

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
