//	Common form field validation functions (e.g., email, password).
class CommonRegExpression {
  static bool mobileNumberValidation(String value) {
    RegExp phoneRegExp = RegExp(r'^[1-9]\d{9}$');
    return phoneRegExp.hasMatch(value);
  }

  static bool validateAtLeastEightCharacter(String value) {
    String pattern = r'^.{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateAtLeastOneDigit(String value) {
    String pattern = r'^(?=.*?[0-9])';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateLowercase(String value) {
    String pattern = r'^(?=.*?[a-z])';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateUpperCase(String value) {
    String pattern = r'^(?=.*?[A-Z])';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateSpecialCharacter(String value) {
    String pattern = r'^(?=.*?[[%+=!@#\$&*~\]-])';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateEmojis(String value) {
    String pattern = r'[\u0080-\uFFFF]'; // Matches emojis and special characters
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static bool validateEmailValidation(String value) {
    String pattern = r'^\w+[\w\.-]*@\w+[\w\.-]+\.[a-zA-Z]{2,3}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value) && value.length <= 50;
  }


}