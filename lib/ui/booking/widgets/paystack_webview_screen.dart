import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackWebViewScreen extends StatefulWidget {
  final String html;

  const PaystackWebViewScreen({super.key, required this.html});

  @override
  State<PaystackWebViewScreen> createState() => _PaystackWebViewScreenState();
}

class _PaystackWebViewScreenState extends State<PaystackWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const _successBase = 'https://paystack.callback/success';
  static const _cancelledBase = 'https://paystack.callback/cancelled';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          final url = request.url;
          if (url.startsWith(_successBase)) {
            final ref = Uri.parse(url).queryParameters['reference'];
            Navigator.of(context).pop(ref);
            return NavigationDecision.prevent;
          }
          if (url.startsWith(_cancelledBase)) {
            Navigator.of(context).pop(null);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.lock, size: 16.sp, color: Colors.green),
            SizedBox(width: 6.w),
            Text('Secure Payment', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: () => Navigator.of(context).pop(null),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
