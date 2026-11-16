import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportService {
  ExportService._();

  static Future<Directory> getExportDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${docs.path}/Kanza_WMS_Exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    } catch (_) {
      final fallback = Directory('${Directory.systemTemp.path}/Kanza_WMS_Exports');
      if (!await fallback.exists()) {
        await fallback.create(recursive: true);
      }
      return fallback;
    }
  }

  /// Exports tabular data to an Excel-compatible UTF-8 BOM CSV file.
  static Future<String> exportToCsv({
    required String fileNamePrefix,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final dir = await getExportDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final safePrefix = fileNamePrefix.replaceAll(RegExp(r'[^\w\u0600-\u06FF_-]'), '_');
    final file = File('${dir.path}/${safePrefix}_$timestamp.csv');

    final buffer = StringBuffer();
    // Write UTF-8 BOM so Microsoft Excel opens Arabic characters properly
    buffer.write('\uFEFF');
    buffer.writeln(headers.map(_escapeCsv).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }

    await file.writeAsBytes(utf8.encode(buffer.toString()), flush: true);
    return file.path;
  }

  static String _escapeCsv(String value) {
    final cleaned = value.replaceAll('"', '""');
    if (cleaned.contains(',') || cleaned.contains('\n') || cleaned.contains('"')) {
      return '"$cleaned"';
    }
    return cleaned;
  }

  static Future<bool> openExportFolder() async {
    final dir = await getExportDirectory();
    final uri = Uri.directory(dir.path);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openExternalLink(String urlOrPath) async {
    if (urlOrPath.trim().isEmpty) return false;
    final trimmed = urlOrPath.trim();
    final uri = trimmed.startsWith('http')
        ? Uri.tryParse(trimmed)
        : Uri.tryParse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(trimmed)}');
    if (uri != null && await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
