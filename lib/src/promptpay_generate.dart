import 'dart:convert';

enum PromptPayAccountType {
  aid,
  mobileNumber,
  nationalId,
  eWalletId,
  bankAccount,
  ota,
  ;

  String get id {
    switch (this) {
      case PromptPayAccountType.aid:
        return '00';
      case PromptPayAccountType.mobileNumber:
        return '01';
      case PromptPayAccountType.nationalId:
        return '02';
      case PromptPayAccountType.eWalletId:
        return '03';
      case PromptPayAccountType.bankAccount:
        return '04';
      case PromptPayAccountType.ota:
        return '05';
    }
  }
}

class PromptPay {
  static String mobileNumber({
    required String mobileNumber,
    required double amount,
  }) {
    return generate(
      accountNumber: _validAccountNumber(mobileNumber)
          .replaceAll(RegExp(r'^0'), '66')
          .padLeft(13, '0'),
      accountType: PromptPayAccountType.mobileNumber,
      amount: amount,
    );
  }

  static String nationalId({
    required String nationalId,
    required double amount,
  }) {
    return generate(
      accountNumber: _validAccountNumber(nationalId),
      accountType: PromptPayAccountType.nationalId,
      amount: amount,
    );
  }

  static String eWalletId({
    required String eWalletId,
    required double amount,
  }) {
    return generate(
      accountNumber: _validAccountNumber(eWalletId),
      accountType: PromptPayAccountType.eWalletId,
      amount: amount,
    );
  }

  static String _validAccountNumber(String accountNumber) {
    return accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String generate({
    required String accountNumber,
    required PromptPayAccountType accountType,
    required double amount,
  }) {
    final List<String> params = [
      /// Field `00`
      /// Payload is `01`
      _value(field: '00', value: '01'),

      /// Field `01`
      /// Type of QR
      /// `11` is reusable.
      /// `12` is one time use.
      _value(
        field: '01',
        value: amount > 0 ? '12' : '11',
      ),

      /// Field `29`
      /// Merchant account information
      _value(
        field: '29',
        value: [
          /// Application ID PromptPay
          _value(field: '00', value: 'A000000677010111'),
          _value(field: accountType.id, value: accountNumber),
        ].join(),
      ),

      /// Field `58`
      /// Country is `TH`
      _value(field: '58', value: 'TH'),

      /// Field `53`: Currency THB is `764`
      /// ref: https://en.wikipedia.org/wiki/ISO_4217
      _value(field: '53', value: '764'),

      /// Field `54`: Amount
      if (amount > 0)
        _value(
          field: '54',
          value: amount.toStringAsFixed(2),
        ),
    ];

    final String rawData = [
      params.join(),

      /// Add Field `63`
      /// Checksum length is 04
      '6304',
    ].join();

    final String result = [
      rawData,
      _crc16(rawData).toRadixString(16).toUpperCase(),
    ].join();

    return result;
  }

  static String _value({
    required String field,
    required String value,
  }) {
    return [
      field,
      value.length.toString().padLeft(2, '0'),
      value,
    ].join();
  }

  static int _crc16(String data) {
    int crc = 0xFFFF;
    for (int index = 0; index < data.length; index++) {
      var x = ((crc >> 8) ^ utf8.encode(data[index])[0]) & 0xFF;
      x ^= x >> 4;
      crc = ((crc << 8) ^ (x << 12) ^ (x << 5) ^ x) & 0xFFFF;
    }
    return crc;
  }
}
