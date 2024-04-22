import 'package:flutter/widgets.dart';
import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PromptPayQrImageView extends StatelessWidget {
  final String accountNumber;
  final PromptPayAccountType accountType;
  final double amount;
  final double? qrSize;

  const PromptPayQrImageView({
    super.key,
    required this.accountNumber,
    required this.accountType,
    required this.amount,
    this.qrSize,
  });

  const PromptPayQrImageView.mobileNumber({
    super.key,
    required this.accountNumber,
    required this.amount,
    this.qrSize,
  }) : accountType = PromptPayAccountType.mobileNumber;

  const PromptPayQrImageView.nationalId({
    super.key,
    required this.accountNumber,
    required this.amount,
    this.qrSize,
  }) : accountType = PromptPayAccountType.nationalId;

  const PromptPayQrImageView.eWalletId({
    super.key,
    required this.accountNumber,
    required this.amount,
    this.qrSize,
  }) : accountType = PromptPayAccountType.eWalletId;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: PromptPay.generate(
        accountNumber: accountNumber,
        accountType: accountType,
        amount: amount,
      ),
      size: qrSize,
    );
  }
}
