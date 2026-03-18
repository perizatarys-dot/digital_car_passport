import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_report.dart';
import '../providers/auth_providers.dart';

class AppPreferencesStore {
  static const _reportSubscriptionKey = 'report_access.has_subscription';
  static const _usedFreeReportsKey = 'report_access.used_free_reports';
  static const _usedFreeHistoryChecksKey =
      'history_access.used_free_history_checks';
  static const _paidHistoryChecksKey = 'history_access.paid_history_checks';
  static const _savedReportsKey = 'account.saved_reports';
  static const _searchHistoryKey = 'account.search_history';
  static const _avatarBase64Key = 'account.avatar_base64';

  static late final SharedPreferences _prefs;

  static Future<void> ensureInitialized() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String _scopedKey(String accountId, String key) => '$accountId.$key';

  static ReportAccessState loadReportAccessState(String accountId) {
    return ReportAccessState(
      hasSubscription:
          _prefs.getBool(_scopedKey(accountId, _reportSubscriptionKey)) ??
              false,
      usedFreeReports:
          _prefs.getInt(_scopedKey(accountId, _usedFreeReportsKey)) ?? 0,
    );
  }

  static Future<void> saveReportAccessState(
    String accountId,
    ReportAccessState state,
  ) async {
    await Future.wait<void>([
      _prefs.setBool(
        _scopedKey(accountId, _reportSubscriptionKey),
        state.hasSubscription,
      ),
      _prefs.setInt(
        _scopedKey(accountId, _usedFreeReportsKey),
        state.usedFreeReports,
      ),
    ]);
  }

  static HistoryAccessState loadHistoryAccessState(String accountId) {
    return HistoryAccessState(
      usedFreeHistoryChecks:
          _prefs.getInt(_scopedKey(accountId, _usedFreeHistoryChecksKey)) ?? 0,
      paidHistoryChecks:
          _prefs.getInt(_scopedKey(accountId, _paidHistoryChecksKey)) ?? 0,
    );
  }

  static Future<void> saveHistoryAccessState(
    String accountId,
    HistoryAccessState state,
  ) async {
    await Future.wait<void>([
      _prefs.setInt(
        _scopedKey(accountId, _usedFreeHistoryChecksKey),
        state.usedFreeHistoryChecks,
      ),
      _prefs.setInt(
        _scopedKey(accountId, _paidHistoryChecksKey),
        state.paidHistoryChecks,
      ),
    ]);
  }

  static AccountGarageState loadAccountGarageState(String accountId) {
    final savedReportsJson =
        _prefs.getStringList(_scopedKey(accountId, _savedReportsKey)) ?? [];
    final searchHistory =
        _prefs.getStringList(_scopedKey(accountId, _searchHistoryKey)) ?? [];

    return AccountGarageState(
      savedReports: savedReportsJson
          .map(
            (item) => SavedReportPreview.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            ),
          )
          .toList(),
      searchHistory: searchHistory,
    );
  }

  static Future<void> saveAccountGarageState(
    String accountId,
    AccountGarageState state,
  ) async {
    await Future.wait<void>([
      _prefs.setStringList(
        _scopedKey(accountId, _savedReportsKey),
        state.savedReports
            .map((report) => jsonEncode(report.toJson()))
            .toList(),
      ),
      _prefs.setStringList(
        _scopedKey(accountId, _searchHistoryKey),
        state.searchHistory,
      ),
    ]);
  }

  static String? loadAvatarBase64(String accountId) {
    return _prefs.getString(_scopedKey(accountId, _avatarBase64Key));
  }

  static Future<void> saveAvatarBase64(
    String accountId,
    String? avatarBase64,
  ) async {
    final key = _scopedKey(accountId, _avatarBase64Key);
    if (avatarBase64 == null || avatarBase64.isEmpty) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, avatarBase64);
  }
}

final appThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class ReportAccessState {
  static const int freeReportLimit = 1;

  final bool hasSubscription;
  final int usedFreeReports;

  const ReportAccessState({
    this.hasSubscription = false,
    this.usedFreeReports = 0,
  });

  bool get hasFreeReportRemaining =>
      !hasSubscription && usedFreeReports < freeReportLimit;

  int get remainingFreeReports => freeReportLimit - usedFreeReports;

  ReportAccessState copyWith({
    bool? hasSubscription,
    int? usedFreeReports,
  }) {
    return ReportAccessState(
      hasSubscription: hasSubscription ?? this.hasSubscription,
      usedFreeReports: usedFreeReports ?? this.usedFreeReports,
    );
  }
}

class ReportAccessNotifier extends StateNotifier<ReportAccessState> {
  ReportAccessNotifier(this._accountId)
      : super(AppPreferencesStore.loadReportAccessState(_accountId));

  final String _accountId;

  bool unlockReport() {
    if (state.hasSubscription) {
      return true;
    }

    if (state.hasFreeReportRemaining) {
      state = state.copyWith(usedFreeReports: state.usedFreeReports + 1);
      AppPreferencesStore.saveReportAccessState(_accountId, state);
      return true;
    }

    return false;
  }

  void activateSubscription() {
    state = state.copyWith(hasSubscription: true);
    AppPreferencesStore.saveReportAccessState(_accountId, state);
  }
}

final reportAccessProvider =
    StateNotifierProvider<ReportAccessNotifier, ReportAccessState>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  final accountId = user?.uid ?? 'signed_out';
  return ReportAccessNotifier(accountId);
});

class HistoryAccessState {
  static const int freeHistoryChecksLimit = 1;

  final int usedFreeHistoryChecks;
  final int paidHistoryChecks;

  const HistoryAccessState({
    this.usedFreeHistoryChecks = 0,
    this.paidHistoryChecks = 0,
  });

  bool get hasFreeHistoryCheckRemaining =>
      usedFreeHistoryChecks < freeHistoryChecksLimit;

  int get remainingFreeHistoryChecks =>
      freeHistoryChecksLimit - usedFreeHistoryChecks;

  bool get hasPaidHistoryCheckRemaining => paidHistoryChecks > 0;

  HistoryAccessState copyWith({
    int? usedFreeHistoryChecks,
    int? paidHistoryChecks,
  }) {
    return HistoryAccessState(
      usedFreeHistoryChecks:
          usedFreeHistoryChecks ?? this.usedFreeHistoryChecks,
      paidHistoryChecks: paidHistoryChecks ?? this.paidHistoryChecks,
    );
  }
}

class HistoryAccessNotifier extends StateNotifier<HistoryAccessState> {
  HistoryAccessNotifier(this._accountId)
      : super(AppPreferencesStore.loadHistoryAccessState(_accountId));

  final String _accountId;

  bool unlockHistoryAccess() {
    if (state.hasFreeHistoryCheckRemaining) {
      state = state.copyWith(
        usedFreeHistoryChecks: state.usedFreeHistoryChecks + 1,
      );
      AppPreferencesStore.saveHistoryAccessState(_accountId, state);
      return true;
    }

    if (state.hasPaidHistoryCheckRemaining) {
      state = state.copyWith(
        paidHistoryChecks: state.paidHistoryChecks - 1,
      );
      AppPreferencesStore.saveHistoryAccessState(_accountId, state);
      return true;
    }

    return false;
  }

  void purchaseHistoryAccess() {
    state = state.copyWith(
      paidHistoryChecks: state.paidHistoryChecks + 1,
    );
    AppPreferencesStore.saveHistoryAccessState(_accountId, state);
  }
}

final historyAccessProvider =
    StateNotifierProvider<HistoryAccessNotifier, HistoryAccessState>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  final accountId = user?.uid ?? 'signed_out';
  return HistoryAccessNotifier(accountId);
});

class AccountGarageState {
  final List<SavedReportPreview> savedReports;
  final List<String> searchHistory;

  const AccountGarageState({
    this.savedReports = const [],
    this.searchHistory = const [],
  });

  bool isSaved(String vin) => savedReports
      .any((report) => report.vin.toUpperCase() == vin.toUpperCase());

  AccountGarageState copyWith({
    List<SavedReportPreview>? savedReports,
    List<String>? searchHistory,
  }) {
    return AccountGarageState(
      savedReports: savedReports ?? this.savedReports,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}

class AccountGarageNotifier extends StateNotifier<AccountGarageState> {
  AccountGarageNotifier(this._accountId)
      : super(AppPreferencesStore.loadAccountGarageState(_accountId));

  final String _accountId;

  Future<void> toggleSavedReport(CarReport report) async {
    final alreadySaved = state.isSaved(report.vehicle.vin);
    if (alreadySaved) {
      await removeSavedReport(report.vehicle.vin);
      return;
    }

    final updated = [
      SavedReportPreview.fromReport(report),
      ...state.savedReports,
    ];
    state = state.copyWith(savedReports: updated);
    await AppPreferencesStore.saveAccountGarageState(_accountId, state);
  }

  Future<void> removeSavedReport(String vin) async {
    final updated = state.savedReports
        .where((report) => report.vin.toUpperCase() != vin.toUpperCase())
        .toList();
    state = state.copyWith(savedReports: updated);
    await AppPreferencesStore.saveAccountGarageState(_accountId, state);
  }

  Future<void> addSearchHistory(String vin) async {
    final normalizedVin = vin.toUpperCase();
    final updated = [
      normalizedVin,
      ...state.searchHistory.where((item) => item != normalizedVin),
    ];
    state = state.copyWith(searchHistory: updated.take(20).toList());
    await AppPreferencesStore.saveAccountGarageState(_accountId, state);
  }
}

final accountGarageProvider =
    StateNotifierProvider<AccountGarageNotifier, AccountGarageState>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  final accountId = user?.uid ?? 'signed_out';
  return AccountGarageNotifier(accountId);
});

class AccountAvatarNotifier extends StateNotifier<String?> {
  AccountAvatarNotifier(this._accountId)
      : super(AppPreferencesStore.loadAvatarBase64(_accountId));

  final String _accountId;

  Future<void> setAvatarBase64(String avatarBase64) async {
    state = avatarBase64;
    await AppPreferencesStore.saveAvatarBase64(_accountId, avatarBase64);
  }

  Future<void> clear() async {
    state = null;
    await AppPreferencesStore.saveAvatarBase64(_accountId, null);
  }
}

final accountAvatarProvider =
    StateNotifierProvider<AccountAvatarNotifier, String?>(
  (ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final accountId = user?.uid ?? 'signed_out';
    return AccountAvatarNotifier(accountId);
  },
);
