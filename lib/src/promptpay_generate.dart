import 'dart:convert';

import 'package:flutter_promptpay/flutter_promptpay.dart';

class PromptPay {
  static Future<String> generate({
    required String accountNumber,
    required double amount,
  }) async {
    try {
      final validAccountNumber =
          accountNumber.replaceAll(RegExp(r'(\D.*?)'), '').trim();

      PromptPayErrorType? validate = PromptPayErrorType.invalidAccountNumber;

      switch (validAccountNumber.length) {
        case 10:
          validate = PromptPayValidator.thaiMobileNumber(
            validAccountNumber,
          );
          break;

        case 13:
          validate = PromptPayValidator.thaiNationalId(
            validAccountNumber,
          );
          break;

        case 15:
          validate = PromptPayValidator.eWalletId(
            validAccountNumber,
          );
          break;

        default:
          break;
      }

      if (validate != null) {
        throw Exception(validate);
      }

      final List<String> params = [
        /// Field `00`
        /// Payload is `01`
        _value(field: '00', value: '01'),

        /// Field `01`
        /// Type of QR
        /// `11` is reusable.
        /// `12` is one time use.
        _value(field: '01', value: '11'),

        /// Field `29`
        /// Merchant account information
        _value(
          field: '29',
          value: _createMerchantAccountInfo(validAccountNumber),
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
    } catch (error) {
      rethrow;
    }
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

  static String _createMerchantAccountInfo(String validAccountNumber) {
    return [
      /// Application ID PromptPay
      _value(field: '00', value: 'A000000677010111'),
      _determineAccountType(validAccountNumber),
    ].join();
  }

  static String _determineAccountType(String validAccountNumber) {
    if (validAccountNumber.length >= 15) {
      /// E-wallet ID
      return _value(field: '03', value: validAccountNumber);
    } else if (validAccountNumber.length >= 13) {
      /// Thai National ID
      return _value(field: '02', value: validAccountNumber);
    } else {
      /// Phone number
      return _value(
        field: '01',
        value:
            validAccountNumber.replaceAll(RegExp(r'^0'), '66').padLeft(13, '0'),
      );
    }
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
