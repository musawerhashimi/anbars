import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/database/database_helper.dart';

/// Creates database backup files, sends them by email and restores them.
class BackupService {
  /// Writes a snapshot of the database into the app cache and returns it.
  Future<File> createBackupFile() async {
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'backups'),
    );
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    final stamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-')
        .replaceAll('T', '_');
    return DatabaseHelper.instance.exportTo(
      p.join(dir.path, 'anbar-backup-$stamp.db'),
    );
  }

  /// Opens the email app with the backup attached and [email] as recipient.
  /// Falls back to the system share sheet when no email app is available.
  Future<void> emailBackup({
    required String email,
    required String subject,
    required String body,
  }) async {
    final file = await createBackupFile();
    final message = '$body\n\n$email';
    try {
      final caps = await FlutterEmailSender.getCapabilities();
      if (caps.canSend) {
        await FlutterEmailSender.send(
          Email(
            recipients: [email],
            subject: subject,
            body: body,
            attachmentPaths: caps.supportsAttachments ? [file.path] : null,
          ),
        );
        return;
      }
    } on FlutterEmailSenderException {
      // No mail app, or the phone blocked the query — use the share sheet.
    } on PlatformException {
      // Older plugin / unexpected platform error.
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, name: p.basename(file.path))],
        subject: subject,
        text: message,
      ),
    );
  }

  /// Lets the user choose a backup file. Returns null if they cancel.
  Future<File?> pickBackupFile() async {
    final picked = await FilePicker.pickFile();
    final path = picked?.path;
    return path == null ? null : File(path);
  }

  Future<void> restore(File backup) =>
      DatabaseHelper.instance.importFrom(backup);
}
