class PromptPayValidator {
  /// Regular Expression: Digits `[0-9]` only.
  static final digitRegex = RegExp(r'[0-9]');

  /// Validate Thai MobileNumber.
  /// 10 digits.
  /// Start With `0` and the second character is 6|8|9
  static String? mobileNumber(String? value) {
    final regex = RegExp(r'^0[689][0-9]{8}$');
    if (value != null &&
        value.trim().isNotEmpty &&
        value.length == 10 &&
        digitRegex.hasMatch(value) &&
        regex.hasMatch(value)) {
      return null;
    } else {
      return 'Invalid Mobile Number';
    }
  }

  /// Validate Thai National ID.
  /// 13 digits.
  static String? nationalId(String? value) {
    if (value != null &&
        value.trim().isNotEmpty &&
        value.length == 13 &&
        digitRegex.hasMatch(value)) {
      int sum = 0;
      for (int i = 0; i < value.length - 1; i++) {
        sum += int.parse(value[i]) * (13 - i);
      }

      int checkDigit = (11 - (sum % 11)) % 10;

      if (checkDigit == int.parse(value[12])) {
        return null;
      } else {
        return 'Invalid National ID';
      }
    } else {
      return 'Invalid National ID';
    }
  }

  /// Validate E-Wallet ID.
  /// 15 characters.
  static String? eWalletId(String? value) {
    if (value != null &&
        value.trim().isNotEmpty &&
        value.length == 15 &&
        digitRegex.hasMatch(value)) {
      return null;
    } else {
      return 'Invalid E-Wallet ID';
    }
  }
}
