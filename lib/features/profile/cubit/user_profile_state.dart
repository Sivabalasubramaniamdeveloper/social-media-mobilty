import '../models/user_profile_model.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final UserProfileModel profile;
  const UserProfileLoaded(this.profile);
}

class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
}
