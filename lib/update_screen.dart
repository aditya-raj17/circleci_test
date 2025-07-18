import 'dart:async';

import 'package:circleci_test/update_service.dart';
import 'package:flutter/material.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool isDownloaded = false;
  bool isDownloading = false;
  late final Timer _timer;
  late int currentPatch;
  late int nextPatch;

  @override
  void initState() {
    getPatchNumners();
    super.initState();
  }
  void getPatchNumners() async {
    currentPatch = await UpdateService.currentPatchNumber();
    nextPatch = await UpdateService.nextPatchNumber();
  }

  void _startDownloadStatusTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      bool downloaded = await UpdateService().isDownloadComplete();
      if (downloaded) {
        setState(() {
          isDownloaded = true;
          isDownloading = false;
          getPatchNumners();
        });
      }
      if (downloaded) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Patch Available! Please update your app.',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text("Current Patch: $currentPatch"),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Download Patch"),
                onPressed: () async {
                  setState(() {
                    isDownloading = true;
                  });
                  await UpdateService().downloadUpdate();
                  _startDownloadStatusTimer();
                },
              ),
              if (isDownloading) const CircularProgressIndicator(),
              if (isDownloaded)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text("Download completed!!"),
                    Text("New Patch : $nextPatch"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text("Restart App to apply"),
                      onPressed: () {
                        UpdateService().restartApp();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
