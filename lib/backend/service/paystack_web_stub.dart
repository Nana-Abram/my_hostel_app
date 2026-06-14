import 'dart:async';

Future<String?> processPaystackWebPayment({
  required String publicKey,
  required String email,
  required int amountInPesewas,
  required String reference,
  required String customerName,
}) async =>
    throw UnsupportedError('Paystack web payment is only available on Flutter Web');
