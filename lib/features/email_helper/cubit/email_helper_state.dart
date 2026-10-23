import 'package:equatable/equatable.dart';
import '../models/email_helper_model.dart';

abstract class EmailHelperState extends Equatable {
  const EmailHelperState();

  @override
  List<Object?> get props => [];
}

class EmailHelperInitial extends EmailHelperState {
  const EmailHelperInitial();
}

class EmailHelperLoading extends EmailHelperState {
  const EmailHelperLoading();
}

class EmailHelperGenerated extends EmailHelperState {
  final EmailGenerationResult result;
  const EmailHelperGenerated(this.result);

  @override
  List<Object?> get props => [result];
}

class EmailHelperSavedEmailsLoaded extends EmailHelperState {
  final List<SavedEmailModel> savedEmails;
  final int count;
  final int limit;

  const EmailHelperSavedEmailsLoaded({
    required this.savedEmails,
    required this.count,
    required this.limit,
  });

  @override
  List<Object?> get props => [savedEmails, count, limit];
}

class EmailHelperError extends EmailHelperState {
  final String message;
  const EmailHelperError(this.message);

  @override
  List<Object?> get props => [message];
}
