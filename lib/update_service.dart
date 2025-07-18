import 'package:circleci_test/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateService {
  // This service is responsible for handling updates in the application.
  // It can include methods to check for updates, download updates, and restart app.
  static bool isDownloading = false;

  static Future<int> currentPatchNumber() async {
    return await ShorebirdCodePush().currentPatchNumber() ?? 0;
  }

  static Future<int> nextPatchNumber() async {
    return await ShorebirdCodePush().nextPatchNumber() ?? 0;
  }

  Future<void> checkForUpdates(BuildContext context) async {
    // Logic to check for updates
    int? current = await currentPatchNumber();
    debugPrint("current patch number: $current");
    final bool isNewPatchAvailable =
        await ShorebirdCodePush().isNewPatchAvailableForDownload();

    if (isNewPatchAvailable) {
      debugPrint("New patch available for download.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpdateScreen()),
      );
    } else {
      debugPrint("No new patch avialable!!");
    }
  }

  Future<void> downloadUpdate() async {
    // Logic to download the update
    isDownloading = true;
    await ShorebirdCodePush().downloadUpdateIfAvailable();
  }

  Future<bool> isDownloadComplete() async {
    return await ShorebirdCodePush().isNewPatchReadyToInstall();
  }

  void restartApp() {
    // Logic to restart app
    SystemNavigator.pop();
  }
}
