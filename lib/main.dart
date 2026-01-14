import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'core/errors/error_boundary.dart';

void main() {
  // Wrap entire app in error zone
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize logging
      await AppLogger.initialize();
      AppLogger.info('App starting', tags: ['lifecycle']);
      
      // Set Flutter error handler
      FlutterError.onError = flutterErrorHandler;
      
      // Handle errors in async code
      PlatformDispatcher.instance.onError = (error, stack) {
        globalErrorHandler(error, stack);
        return true;
      };
      
      runApp(
        const ProviderScope(
          child: AdsumApp(),
        ),
      );
    },
    globalErrorHandler,
  );
}

class AdsumApp extends ConsumerWidget {
  const AdsumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Adsum',
      theme: AppTheme.lightTheme,
      // TODO: Add dark theme
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      
      // Custom error widget for production
      builder: (context, child) {
        // Custom error widget in release mode
        if (!kDebugMode) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return _ProductionErrorWidget(details: details);
          };
        }
        
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Production-friendly error widget (no red screen)
class _ProductionErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  
  const _ProductionErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re working to fix this. Please restart the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
