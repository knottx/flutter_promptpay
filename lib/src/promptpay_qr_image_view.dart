import 'package:flutter/widgets.dart';
import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PromptPayQrImageView extends StatefulWidget {
  final String accountNumber;
  final double amount;
  final double? qrSize;

  const PromptPayQrImageView({
    super.key,
    required this.accountNumber,
    required this.amount,
    this.qrSize,
  });

  @override
  State<PromptPayQrImageView> createState() => _PromptPayQrImageViewState();
}

class _PromptPayQrImageViewState extends State<PromptPayQrImageView> {
  String data = '';

  @override
  void initState() {
    super.initState();
    PromptPay.generate(
      accountNumber: widget.accountNumber,
      amount: widget.amount,
    ).then(
      (value) {
        setState(() {
          data = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return data.trim().isNotEmpty
        ? QrImageView(
            data: '',
            size: widget.qrSize,
          )
        : SizedBox(
            width: widget.qrSize,
            height: widget.qrSize,
          );
  }
}
