import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    expect(
      PromptPay.generate(
        accountNumber: '0123456789',
        accountType: PromptPayAccountType.mobileNumber,
        amount: 0,
      ),
      '00020101021129340016A000000677010111011001234567895802TH53037646304E36B',
    );

    expect(
      PromptPay.generate(
        accountNumber: '0123456789',
        accountType: PromptPayAccountType.mobileNumber,
        amount: 50,
      ),
      '00020101021229340016A000000677010111011001234567895802TH5303764540550.0063044E73',
    );

    expect(
      PromptPay.generate(
        accountNumber: '0123456789012',
        accountType: PromptPayAccountType.nationalId,
        amount: 0,
      ),
      '00020101021129370016A000000677010111021301234567890125802TH53037646304CBD',
    );

    expect(
      PromptPay.generate(
        accountNumber: '0123456789012',
        accountType: PromptPayAccountType.nationalId,
        amount: 50,
      ),
      '00020101021229370016A000000677010111021301234567890125802TH5303764540550.006304E152',
    );

    expect(
      PromptPay.generate(
        accountNumber: '012345678901234',
        accountType: PromptPayAccountType.eWalletId,
        amount: 0,
      ),
      '00020101021129390016A00000067701011103150123456789012345802TH530376463049781',
    );

    expect(
      PromptPay.generate(
        accountNumber: '012345678901234',
        accountType: PromptPayAccountType.eWalletId,
        amount: 50,
      ),
      '00020101021229390016A00000067701011103150123456789012345802TH5303764540550.0063048F3D',
    );
  });
}
