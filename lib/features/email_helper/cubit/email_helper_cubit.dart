import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import '../models/email_helper_model.dart';
import '../service/email_helper_service.dart';
import 'email_helper_state.dart';

class EmailHelperCubit extends Cubit<EmailHelperState> {
  final EmailHelperService _service;

  EmailHelperCubit({EmailHelperService? service})
    : _service = service ?? EmailHelperService(),
      super(const EmailHelperInitial());

  Future<void> generateEmail({
    required String instructions,
    String tone = 'Professional',
  }) async {
    emit(const EmailHelperLoading());
    try {
      final res = await _service.generateEmail(
        instructions: instructions,
        tone: tone,
      );
      emit(EmailHelperGenerated(res));
    } catch (e) {
      emit(EmailHelperError(e.toString()));
    }
  }

  Future<void> loadSavedEmails(PlanTier tier) async {
    try {
      final emails = await _service.getSavedEmails();
      final count = emails.length;
      final limit = _limitForTier(tier);
      emit(
        EmailHelperSavedEmailsLoaded(
          savedEmails: emails,
          count: count,
          limit: limit,
        ),
      );
    } catch (e) {
      emit(EmailHelperError(e.toString()));
    }
  }

  Future<bool> saveEmail({
    required String label,
    required String subject,
    required String body,
    required String tone,
    String? recipient,
    required PlanTier tier,
  }) async {
    try {
      if (state is EmailHelperSavedEmailsLoaded &&
          (state as EmailHelperSavedEmailsLoaded).count >=
              _limitForTier(tier)) {
        final limit = _limitForTier(tier);
        emit(
          EmailHelperError(
            'Saved email limit reached for your plan ($limit emails). Please upgrade or delete older saved emails.',
          ),
        );
        return false;
      }

      final email = SavedEmailModel(
        userId: await UserHelper.getCurrentUserId(),
        label: label.trim().isEmpty ? 'General' : label.trim(),
        subject: subject,
        body: body,
        tone: tone,
        recipient: recipient,
        createdAt: DateTime.now(),
      );

      await _service.saveEmailDraft(email);
      await loadSavedEmails(tier);
      return true;
    } catch (e) {
      emit(EmailHelperError(e.toString()));
      return false;
    }
  }

  Future<void> deleteEmail(String id, PlanTier tier) async {
    try {
      await _service.deleteSavedEmail(id);
      await loadSavedEmails(tier);
    } catch (e) {
      emit(EmailHelperError(e.toString()));
    }
  }

  int _limitForTier(PlanTier tier) => switch (tier) {
    PlanTier.basic => 5,
    PlanTier.pro => 20,
    PlanTier.premium => 50,
  };
}
