import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();

  static StreamSubscription? _sub;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint('Deep link masuk: $uri');

      handleUri(uri, navigatorKey);
    });
  }

  static void handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    final host = uri.host;

    debugPrint('HOST: $host');

    if (host == 'payment-success') {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil 🎉'),
        ),
      );

      return;
    }

    if (host == 'payment-pending') {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran masih pending ⏳'),
        ),
      );

      return;
    }

    if (host == 'payment-error') {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran gagal ❌'),
        ),
      );

      return;
    }
  }

  static void dispose() {
    _sub?.cancel();
  }
}
