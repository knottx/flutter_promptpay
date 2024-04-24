import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_promptpay/flutter_promptpay.dart';
import 'package:flutter_promptpay_example/validator.dart';

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

  PromptPayAccountType accountType = PromptPayAccountType.mobileNumber;

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PromptPayAccountType.mobileNumber,
              PromptPayAccountType.nationalId,
              PromptPayAccountType.eWalletId,
            ]
                .map(
                  (e) => ChoiceChip(
                    label: Text(
                      e.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accountType == e ? onPrimaryColor : primaryColor,
                      ),
                    ),
                    selected: accountType == e,
                    selectedColor: primaryColor,
                    checkmarkColor: onPrimaryColor,
                    side: BorderSide(
                      width: 2,
                      color: primaryColor,
                    ),
                    onSelected: (selected) {
                      _onSelectedAccountType(e);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          TextFormField(
            decoration: InputDecoration(
              labelText: accountType.title,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                gapPadding: 4,
              ),
            ),
            maxLines: 1,
            keyboardType: TextInputType.number,
            validator: (value) {
              switch (accountType) {
                case PromptPayAccountType.mobileNumber:
                  return PromptPayValidator.mobileNumber(value);
                case PromptPayAccountType.nationalId:
                  return PromptPayValidator.nationalId(value);
                case PromptPayAccountType.eWalletId:
                  return PromptPayValidator.eWalletId(value);
                default:
                  return null;
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onSaved: (newValue) {
              accountNumberText = newValue?.trim() ?? '';
            },
            onChanged: (value) {
              onChanged();
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
            onChanged: (value) {
              onChanged();
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
                    accountType: accountType,
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
        ],
      ),
    );
  }

  void _onSelectedAccountType(PromptPayAccountType newAccountType) {
    if (accountType == newAccountType) return;
    accountType = newAccountType;
    onChanged();
  }

  void onChanged() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      amount = double.tryParse(amountText) ?? 0.0;

      final result = PromptPay.generate(
        accountNumber: accountNumberText,
        accountType: accountType,
        amount: amount,
      );

      promptPayQrData = result;
    } else {
      accountNumberText = '';
      promptPayQrData = '';
    }
    setState(() {});
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
}

extension PromptPayAccountTypeExtension on PromptPayAccountType {
  String get title {
    switch (this) {
      case PromptPayAccountType.aid:
        return 'AID';
      case PromptPayAccountType.mobileNumber:
        return 'Mobile Number';
      case PromptPayAccountType.nationalId:
        return 'National ID';
      case PromptPayAccountType.eWalletId:
        return 'E-Wallet ID';
      case PromptPayAccountType.bankAccount:
        return 'Bank Account';
      case PromptPayAccountType.ota:
        return 'OTA';
    }
  }
}
