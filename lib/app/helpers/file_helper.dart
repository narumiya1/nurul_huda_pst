import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'config.dart';

class FileHelper {
  static Future<void> downloadAndOpenFile(String path,
      {String? filename}) async {
    try {
      if (path.isEmpty) return;

      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          Get.back(); // close loading
          Get.snackbar('Izin Ditolak',
              'Akses penyimpanan dibutuhkan untuk mengunduh file.');
          return;
        }
      }

      const String scheme = ApiConfig.useHttps ? "https" : "http";
      final String host = ApiConfig.baseUrlAddress;
      final String portStr =
          ApiConfig.port.isNotEmpty ? ":${ApiConfig.port}" : "";

      final String fullUrl = path.startsWith('http')
          ? path
          : "$scheme://$host$portStr/storage/${path.replaceFirst('public/', '')}";

      final response = await http.get(Uri.parse(fullUrl));

      Get.back(); // close loading

      if (response.statusCode == 200) {
        final Directory? directory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

        final String name = filename ?? path.split('/').last;
        final String filePath = "${directory!.path}/$name";
        final File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar('Sukses', 'File berhasil diunduh.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () {
                OpenFilex.open(filePath);
              },
              child: const Text('Buka', style: TextStyle(color: Colors.white)),
            ));

        // Auto open after download
        await OpenFilex.open(filePath);
      } else {
        Get.snackbar(
            'Gagal', 'Gagal mengunduh file (HTTP ${response.statusCode})');
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Error', 'Terjadi kesalahan saat mengunduh: $e');
    }
  }
}
