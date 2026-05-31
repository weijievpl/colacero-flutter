import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

/// Sync status provider — watches pending actions count + connectivity
final syncStatusProvider = StreamProvider<SyncState>((ref) {
  final db = ref.watch(appDatabaseProvider);

  // Combine pending count stream with connectivity stream
  return db.watchPendingActionsCount().asyncMap((count) async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = !results.every((r) => r == ConnectivityResult.none);
    return SyncState(
      pendingCount: count,
      isOnline: isOnline,
      lastSyncAt: null,
    );
  });
});

class SyncState {
  final int pendingCount;
  final bool isOnline;
  final DateTime? lastSyncAt;
  final bool isSyncing;
  final String? lastError;

  const SyncState({
    required this.pendingCount,
    required this.isOnline,
    this.lastSyncAt,
    this.isSyncing = false,
    this.lastError,
  });

  SyncState copyWith({
    int? pendingCount,
    bool? isOnline,
    DateTime? lastSyncAt,
    bool? isSyncing,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isOnline: isOnline ?? this.isOnline,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

/// Compact sync status bar for Dashboard header
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAsync = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return syncAsync.when(
      data: (state) {
        if (state.pendingCount == 0 && state.isOnline && state.lastError == null) {
          return const SizedBox.shrink();
        }

        Color bgColor;
        IconData icon;
        String label;

        if (state.lastError != null) {
          bgColor = cs.error.withValues(alpha: 0.1);
          icon = Icons.sync_problem_rounded;
          label = '${state.lastError}';
        } else if (!state.isOnline) {
          bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
          icon = Icons.wifi_off_rounded;
          label = '${state.pendingCount} pending';
        } else if (state.isSyncing) {
          bgColor = cs.primaryContainer.withValues(alpha: 0.3);
          icon = Icons.sync_rounded;
          label = 'Syncing...';
        } else if (state.pendingCount > 0) {
          bgColor = cs.primary.withValues(alpha: 0.08);
          icon = Icons.cloud_upload_outlined;
          label = '${state.pendingCount} pending sync';
        } else {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (state.isSyncing)
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                )
              else
                Icon(icon, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (state.pendingCount > 0 || state.lastError != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.invalidate(syncStatusProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
