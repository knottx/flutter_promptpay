import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    expect(
      PromptPay.generate(
        accountNumber: '0887776655',
        amount: 0,
      ),
      '00020101021129370016A000000677010111011300668877766555802TH53037646304FF63',
    );

    expect(
      PromptPay.generate(
        accountNumber: '0887776655',
        amount: 50,
      ),
      '00020101021129370016A000000677010111011300668877766555802TH5303764540550.0063043F92',
    );
  });
}
