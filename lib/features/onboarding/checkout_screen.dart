import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../theme/app_theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> onboardData;

  const CheckoutScreen({super.key, required this.onboardData});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  WebViewController? _webViewController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCheckout();
  }

  Future<void> _initCheckout() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post(
        Endpoints.onboard,
        data: widget.onboardData,
      );
      final checkoutUrl = response.data['checkoutUrl'] as String?;
      if (checkoutUrl == null) {
        setState(() {
          _loading = false;
          _error = 'No se pudo obtener el enlace de pago.';
        });
        return;
      }
      _setupWebView(checkoutUrl);
    } on DioException catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error al preparar el pago: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Ocurrió un error inesperado.';
      });
    }
  }

  void _setupWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.navigate;

          if (uri.queryParameters.containsKey('welcome') &&
              uri.queryParameters['welcome'] == 'true') {
            if (mounted) context.go('/waiting');
            return NavigationDecision.prevent;
          }

          if (uri.queryParameters.containsKey('canceled') &&
              uri.queryParameters['canceled'] == 'true') {
            if (mounted) context.go('/tier', extra: widget.onboardData);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));

    setState(() {
      _webViewController = controller;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pago seguro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/tier', extra: widget.onboardData),
        ),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _loading = true;
                        });
                        _initCheckout();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (_webViewController != null)
            WebViewWidget(controller: _webViewController!),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
        ],
      ),
    );
  }
}
