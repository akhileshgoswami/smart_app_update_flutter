import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_app_update_flutter/smart_app_update_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateBottomSheet {
  static RxBool isUpdateDialogShowing = false.obs;

  static Future<void> showUpdateDialog(
    String currentVersion,
    CustomUpdateVersion newVersion,
    bool forceUpdate, {
    String? notes,
    int? totalMinutes,
  }) async {
    final info = await PackageInfo.fromPlatform();
    String? target = newVersion.redirectLink ?? '';

    isUpdateDialogShowing.value = true;

    Get.bottomSheet(
      isDismissible: false,
      PopScope(
        canPop: false,
        child: Container(
          width: Get.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(Get.width * 0.05), // ✅ replaced SizeConfig
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "Update Available!",
                style: TextStyle(
                  fontSize: Get.height * 0.03, // ✅ replaced SizeConfig
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'A new version of ${info.appName} is available!\n'
                'Version ${newVersion.newVersion ?? "N/A"} is now available; you have $currentVersion.\n'
                'Please update it now.',
                style: TextStyle(
                  fontSize: Get.height * 0.018, // ✅ replaced SizeConfig
                  color: Colors.black38,
                ),
                textAlign: TextAlign.start,
              ),
              notes != null
                  ? Text(
                      notes,
                      style: TextStyle(
                        fontSize: Get.height * 0.018, // ✅ replaced SizeConfig
                        color: Colors.black38,
                      ),
                      textAlign: TextAlign.start,
                    )
                  : SizedBox(),
              const SizedBox(height: 10),
              const Divider(),

              // Update button
              GestureDetector(
                onTap: () async {
                  if (Get.isBottomSheetOpen!) Get.back();
                  isUpdateDialogShowing.value = false;

                  if (target.isEmpty) return;

                  final uri = Uri.parse(target);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: Container(
                  height: Get.height * 0.055, // ✅ dynamic height
                  width: Get.width,
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  child: const Text(
                    "Update app now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Maybe later button (optional)
              if (!forceUpdate)
                TextButton(
                  onPressed: () async {
                    if (Get.isBottomSheetOpen!) Get.back();
                    isUpdateDialogShowing.value = false;
                    String currentDateTime = Utility.addHours(totalMinutes!);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString("current_date", currentDateTime);
                  },
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
      enableDrag: !forceUpdate,
    ).then((_) {
      isUpdateDialogShowing.value = false;
    });
  }

  static Future<void> testdialog() {
    return Get.bottomSheet(
      isDismissible: true,
      PopScope(
        canPop: false,
        child: Container(
          width: Get.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(Get.width * 0.05), // ✅ replaced SizeConfig
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "Update Available!",
                style: TextStyle(
                  fontSize: Get.height * 0.03, // ✅ replaced SizeConfig
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'Smart App Update has been successfully configured.',
                style: TextStyle(
                  fontSize: Get.height * 0.018, // ✅ replaced SizeConfig
                  color: Colors.black38,
                ),
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: 10),
              const Divider(),

              // Update button
              GestureDetector(
                onTap: () async {
                  Get.back();
                },
                child: Container(
                  height: Get.height * 0.055, // ✅ dynamic height
                  width: Get.width,
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
      ),
    );
  }
}
