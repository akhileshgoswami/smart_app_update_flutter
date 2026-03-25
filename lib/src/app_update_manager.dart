import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_app_update_flutter/smart_app_update_flutter.dart';

/// App Update Manager
/// Checks the latest app version from API, Play Store, or App Store.
class AppUpdateManager {
  /// Main entry point for checking and prompting app updates.
  static Future<void> checkAndPrompt(
      {
      // Uri? apiEndpoint,
      // required int totalMinutes,
      String? notes,
      int? repeat_totalminutes = 60,
      bool forceUpdate = false,
      bool testDebuge = false,
      bool isAndroidTV = false}) async {
    if (testDebuge) {
      if (kDebugMode) {
        UpdateBottomSheet.testdialog();
        return;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updateLaterDateTime = "";
    try {
      updateLaterDateTime = prefs.getString("current_date")!;
    } catch (_) {}

    if (updateLaterDateTime.isNotEmpty) {
      // print(Utility.isHoursPassed(updateLaterDateTime, repeat_totalminutes!));
      if (!Utility.isHoursPassed(updateLaterDateTime)) {
        return;
      }
    }
    final info = await PackageInfo.fromPlatform();
    CustomUpdateVersion? data;

    try {
      // If API endpoint provided, fetch from API

      // Otherwise fetch from platform store
      if (Platform.isAndroid) {
        data = await _fetchFromPlayStore(info.packageName, isTV: isAndroidTV);
      } else if (Platform.isIOS) {
        data = await _fetchFromAppStore(info.packageName);
      }
    } catch (e) {
      return;
    }

    // If no data or version found, stop
    if (data == null || data.newVersion == null || data.newVersion!.isEmpty) {
      return;
    }

    // Compare versions properly (semantic comparison)
    final isUpdateAvailable =
        _isNewVersionAvailable(info.version, data.newVersion!);

    if (!isUpdateAvailable) {
      return; // No update required
    }

    // Avoid showing multiple dialogs
    if (UpdateBottomSheet.isUpdateDialogShowing.value) return;

    // Show update dialog
    await UpdateBottomSheet.showUpdateDialog(
      // ignore: use_build_context_synchronously

      info.version,
      data,
      forceUpdate,
      notes: notes,
      totalMinutes: repeat_totalminutes,
      isAndroidTV: isAndroidTV,
    );
  }

  /// Proper semantic version comparison.
  static bool _isNewVersionAvailable(String current, String latest) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final latestParts = latest.split('.').map(int.tryParse).toList();

    final maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (int i = 0; i < maxLength; i++) {
      final currentPart = (i < currentParts.length && currentParts[i] != null)
          ? currentParts[i]!
          : 0;
      final latestPart = (i < latestParts.length && latestParts[i] != null)
          ? latestParts[i]!
          : 0;

      if (latestPart > currentPart) return true; // Newer available
      if (latestPart < currentPart) return false; // Current is newer
    }

    return false; // Versions are equal
  }

  /// Fetches the latest version from the Google Play Store (best-effort scraping).
  static Future<CustomUpdateVersion?> _fetchFromPlayStore(String packageName,
      {bool isTV = false}) async {
    try {
      final uri = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName&hl=en&gl=US');

      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final body = res.body;

      // Improved and stable regex for extracting the version from embedded JSON
      final regexp = RegExp(r'\[\[\["(\d+(?:\.\d+)+)"\]\]');
      final match = regexp.firstMatch(body);
      final found = match?.group(1);

      if (found == null || found.isEmpty) {
        return null;
      }

      // On Android TV use market:// scheme so the TV Play Store app opens directly
      final redirectLink = isTV
          ? 'market://details?id=$packageName'
          : 'https://play.google.com/store/apps/details?id=$packageName';

      return CustomUpdateVersion(
        newVersion: found,
        redirectLink: redirectLink,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetches the latest version from the App Store.
  static Future<CustomUpdateVersion?> _fetchFromAppStore(
      String bundleId) async {
    try {
      final uri =
          Uri.https('itunes.apple.com', '/lookup', {'bundleId': bundleId});
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final results = (json['results'] as List?) ?? [];
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final latestVersion = (first['version'] ?? '').toString();
      final trackViewUrl = (first['trackViewUrl'] ?? '').toString();

      if (latestVersion.isEmpty) return null;

      return CustomUpdateVersion(
        newVersion: latestVersion,
        redirectLink: trackViewUrl,
      );
    } catch (e) {
      return null;
    }
  }
}
