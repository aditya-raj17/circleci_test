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
  late Timer _timer;
  int? currentPatch;
  int? nextPatch;

  @override
  void initState() {
    super.initState();
    _loadPatchNumbers();
  }

  Future<void> _loadPatchNumbers() async {
    currentPatch = await UpdateService.currentPatchNumber();
    nextPatch = await UpdateService.nextPatchNumber();
    if (mounted) setState(() {});
  }

  void _startDownloadStatusTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      bool downloaded = await UpdateService().isDownloadComplete();
      if (downloaded) {
        _timer.cancel();
        await _loadPatchNumbers();
        setState(() {
          isDownloaded = true;
          isDownloading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.system_update, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Update Available!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A new patch is ready to be downloaded.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
      
                  // Patch numbers
                  if (currentPatch != null)
                    Text(
                      "Current Patch: $currentPatch",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 16),
      
                  // Download button
                  if (!isDownloaded)
                    ElevatedButton(
                      onPressed: isDownloading
                          ? null
                          : () async {
                              setState(() {
                                isDownloading = true;
                              });
                              await UpdateService().downloadUpdate();
                              _startDownloadStatusTimer();
                            },
                      child: isDownloading ? const Text("Downloading...") : const Text("Download Patch"),
                    ),
      
                  if (isDownloading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
      
                  if (isDownloaded) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Patch downloaded successfully!",
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                    if (nextPatch != null)
                      Text(
                        "New Patch: $nextPatch",
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        UpdateService().restartApp();
                      },
                      child: const Text("Restart App to Apply"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
