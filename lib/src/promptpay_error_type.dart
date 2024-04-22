enum PromptPayErrorType {
  invalidAccountNumber,
  invalidMobileNumber,
  invalidThaiNationalId,
  invalidEWalletId,
  ;

  @override
  String toString() {
    switch (this) {
      case PromptPayErrorType.invalidAccountNumber:
        return 'Invalid Account Number';
      case PromptPayErrorType.invalidMobileNumber:
        return 'Invalid Mobile Number';
      case PromptPayErrorType.invalidThaiNationalId:
        return 'Invalid Thai National ID';
      case PromptPayErrorType.invalidEWalletId:
        return 'Invalid E-Wallet ID';
    }
  }
}
