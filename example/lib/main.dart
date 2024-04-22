import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_promptpay/flutter_promptpay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PromptPay Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController scrollController = ScrollController();

  final GlobalKey<FormState> formKey = GlobalKey();

  String accountNumberText = '';
  String amountText = '';

  double amount = 0.0;

  String promptPayQrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: _body(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Mobile Number / Thai National ID / E-Wallet ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                gapPadding: 4,
              ),
            ),
            maxLines: 1,
            keyboardType: TextInputType.number,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isNotEmpty) {
                switch (value.length) {
                  case 10:
                    return PromptPayValidator.thaiMobileNumber(
                      value,
                    )?.toString();

                  case 13:
                    return PromptPayValidator.thaiNationalId(
                      value,
                    )?.toString();

                  case 15:
                    return PromptPayValidator.eWalletId(
                      value,
                    )?.toString();

                  default:
                    return PromptPayErrorType.invalidAccountNumber.toString();
                }
              } else {
                return 'Required';
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onSaved: (newValue) {
              accountNumberText = newValue?.trim() ?? '';
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                gapPadding: 4,
              ),
            ),
            maxLines: 1,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
            ],
            onSaved: (newValue) {
              amountText = newValue?.trim() ?? '';
            },
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accountNumberText.isNotEmpty)
                Center(
                  child: PromptPayQrImageView(
                    accountNumber: accountNumberText,
                    amount: amount,
                    qrSize: 200,
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SelectableText(
                          promptPayQrData,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (promptPayQrData.isNotEmpty)
                          ? () => _onTapCopy(promptPayQrData)
                          : null,
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _onTapGenerate,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Generate'),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapGenerate() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        amount = double.tryParse(amountText) ?? 0.0;

        final result = await PromptPay.generate(
          accountNumber: accountNumberText,
          amount: amount,
        );

        setState(() {
          promptPayQrData = result;
        });
      } catch (error) {
        promptPayQrData = error.toString();
      }
    }
  }

  void _onTapCopy(
    String data,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: data),
    );
    HapticFeedback.lightImpact();
    _showCopied();
  }

  void _showCopied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.abc),
            Text('Copied!'),
          ],
        ),
      ),
    );
  }

  void _alertError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
