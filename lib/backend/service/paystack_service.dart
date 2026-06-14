import 'package:my_hostel_app/config/app_secrets.dart';

class PaystackService {
  static const String publicKey = AppSecrets.paystackPublicKey;

  String generateReference() => 'HH_${DateTime.now().millisecondsSinceEpoch}';

  String buildPaymentHtml({
    required double amountInGHS,
    required String email,
    required String customerName,
    required String reference,
  }) {
    final amountInPesewas = (amountInGHS * 100).toInt();
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Secure Payment</title>
  <script src="https://js.paystack.co/v1/inline.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #f5f6fa; display: flex; align-items: center;
           justify-content: center; height: 100vh; font-family: sans-serif; }
    .loading { color: #555; font-size: 15px; }
  </style>
</head>
<body>
  <p class="loading">Opening secure payment...</p>
  <script>
    window.onload = function () {
      var handler = PaystackPop.setup({
        key: '${PaystackService.publicKey}',
        email: '$email',
        amount: $amountInPesewas,
        currency: 'GHS',
        ref: '$reference',
        metadata: {
          custom_fields: [{
            display_name: "Customer",
            variable_name: "customer_name",
            value: "$customerName"
          }]
        },
        onClose: function () {
          window.location.href = 'https://paystack.callback/cancelled';
        },
        callback: function (response) {
          window.location.href =
            'https://paystack.callback/success?reference=' + response.reference;
        }
      });
      handler.openIframe();
    };
  </script>
</body>
</html>
''';
  }
}
