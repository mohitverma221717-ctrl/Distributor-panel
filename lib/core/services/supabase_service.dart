import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for Supabase Backend
class SupabaseConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool isConfigured;

  const SupabaseConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.isConfigured = false,
  });

  factory SupabaseConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    final configured =
        url.isNotEmpty && key.isNotEmpty && !url.contains('YOUR_SUPABASE');

    return SupabaseConfig(
      supabaseUrl: url,
      supabaseAnonKey: key,
      isConfigured: configured,
    );
  }
}

/// Supabase Service with robust offline fallback
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  late final SupabaseConfig config;
  Dio? _dio;
  bool _isOfflineDemoMode = true;

  SupabaseService._internal() {
    config = SupabaseConfig.fromEnvironment();
    _isOfflineDemoMode = !config.isConfigured;

    if (config.isConfigured) {
      _dio = Dio(
        BaseOptions(
          baseUrl: '${config.supabaseUrl}/rest/v1',
          headers: {
            'apikey': config.supabaseAnonKey,
            'Authorization': 'Bearer ${config.supabaseAnonKey}',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation',
          },
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      if (kDebugMode) {
        debugPrint(
          '[ShopEasy SupabaseService] Initialized with live URL: ${config.supabaseUrl}',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          '[ShopEasy SupabaseService] Running in Offline Demo Mode. '
          'Provide SUPABASE_URL and SUPABASE_ANON_KEY to sync with cloud database.',
        );
      }
    }
  }

  bool get isOfflineDemoMode => _isOfflineDemoMode;
  bool get isConnectedToCloud => config.isConfigured && !_isOfflineDemoMode;

  /// Generic fetch with local cached fallback
  Future<List<Map<String, dynamic>>> queryTable(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
  }) async {
    if (_isOfflineDemoMode || _dio == null) {
      return _loadFromLocalCache(table);
    }

    try {
      final response = await _dio!.get(
        '/$table',
        queryParameters: {'select': ?select, ...?filters},
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = List<Map<String, dynamic>>.from(response.data);
        await _saveToLocalCache(table, list);
        return list;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[ShopEasy Supabase] Remote query failed, falling back to local cache: $e',
        );
      }
    }

    return _loadFromLocalCache(table);
  }

  /// Insert record with local cache persistence
  Future<Map<String, dynamic>?> insertRecord(
    String table,
    Map<String, dynamic> data,
  ) async {
    if (_isOfflineDemoMode || _dio == null) {
      final list = await _loadFromLocalCache(table);
      list.insert(0, data);
      await _saveToLocalCache(table, list);
      return data;
    }

    try {
      final response = await _dio!.post('/$table', data: data);
      if (response.statusCode == 201 &&
          response.data is List &&
          (response.data as List).isNotEmpty) {
        return (response.data as List).first as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[ShopEasy Supabase] Remote insert failed, saving locally: $e',
        );
      }
      final list = await _loadFromLocalCache(table);
      list.insert(0, data);
      await _saveToLocalCache(table, list);
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> _loadFromLocalCache(String table) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('supabase_cache_$table');
      if (str != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(str) as List);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToLocalCache(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_cache_$table', jsonEncode(data));
    } catch (_) {}
  }
}
