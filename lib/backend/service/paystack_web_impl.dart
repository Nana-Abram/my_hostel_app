// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

const _paystackScriptId = 'paystack-inline-js';

/// Loads Paystack's inline.js on first use instead of blocking every page
/// load with it — checkout is a rare action relative to browsing.
Future<void> _ensurePaystackScriptLoaded() {
  if (js.context.hasProperty('PaystackPop')) {
    return Future.value();
  }
  final existing = html.document.getElementById(_paystackScriptId);
  if (existing != null) {
    // Already injected by a previous call; wait for it to finish loading.
    final completer = Completer<void>();
    existing.addEventListener('load', (_) => completer.complete());
    if (js.context.hasProperty('PaystackPop')) completer.complete();
    return completer.future;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..id = _paystackScriptId
    ..src = 'https://js.paystack.co/v1/inline.js';
  script.addEventListener('load', (_) => completer.complete());
  html.document.head!.append(script);
  return completer.future;
}

Future<String?> processPaystackWebPayment({
  required String publicKey,
  required String email,
  required int amountInPesewas,
  required String reference,
  required String customerName,
}) async {
  await _ensurePaystackScriptLoaded();

  final completer = Completer<String?>();
  late html.EventListener listener;

  listener = (html.Event event) {
    if (event is! html.MessageEvent) return;
    final data = event.data;
    if (data == null) return;

    final type = data['type']?.toString();
    if (type == 'paystack_success') {
      if (!completer.isCompleted) {
        completer.complete(data['reference']?.toString());
      }
      html.window.removeEventListener('message', listener);
    } else if (type == 'paystack_closed') {
      if (!completer.isCompleted) completer.complete(null);
      html.window.removeEventListener('message', listener);
    }
  };

  html.window.addEventListener('message', listener);

  // Inject a script tag that opens the Paystack inline popup.
  // On success/close it posts a message back to Flutter via window.postMessage.
  final script = html.document.createElement('script') as html.ScriptElement;
  script.text = """
    (function() {
      var h = PaystackPop.setup({
        key: '$publicKey',
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
        onClose: function() {
          window.postMessage({ type: 'paystack_closed' }, '*');
        },
        callback: function(r) {
          window.postMessage({ type: 'paystack_success', reference: r.reference }, '*');
        }
      });
      h.openIframe();
    })();
  """;
  html.document.body!.append(script);

  return completer.future;
}
