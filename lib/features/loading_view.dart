// features/auth/loading/session_loading_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moot_web/core/utils/global_constants.dart';

class SessionLoadingView extends ConsumerStatefulWidget {
  const SessionLoadingView({super.key});

  @override
  ConsumerState<SessionLoadingView> createState() =>
      _SessionLoadingViewState();
}

class _SessionLoadingViewState extends ConsumerState<SessionLoadingView> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(userDataProvider);

    // Still reading from prefs
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Loading done: redirect once
    if (!_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (authState.isAuthenticated) {
          context.go('/dashboard');
        } else {
          context.go('/login');
        }
      });
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
