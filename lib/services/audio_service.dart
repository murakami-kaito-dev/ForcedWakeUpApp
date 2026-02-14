import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:volume_controller/volume_controller.dart';
import '../models/alarm_sound.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  double? _previousVolume;

  /// Resolve custom sound path — if stored path doesn't exist,
  /// try to find the file by name in the app documents directory.
  /// This handles iOS container UUID changes between app deployments.
  Future<String?> _resolveCustomSoundPath(String storedPath) async {
    if (await File(storedPath).exists()) return storedPath;

    // Extract filename and look in current documents directory
    final fileName = storedPath.split('/').last;
    final appDir = await getApplicationDocumentsDirectory();
    final resolvedPath = '${appDir.path}/$fileName';
    if (await File(resolvedPath).exists()) return resolvedPath;

    return null;
  }

  Future<void> playAlarm({
    String soundId = 'fanfare',
    double volume = 1.0,
    String? customSoundPath,
  }) async {
    try {
      VolumeController().showSystemUI = false;
      _previousVolume = await VolumeController().getVolume();
      VolumeController().setVolume(volume);

      if (soundId == 'custom' && customSoundPath != null) {
        final resolvedPath = await _resolveCustomSoundPath(customSoundPath);
        if (resolvedPath != null) {
          await _player.setFilePath(resolvedPath);
        } else {
          // Custom file not found — fall back to default
          final sound = AlarmSound.fromId('fanfare');
          await _player.setAsset(sound.assetPath);
        }
      } else {
        final sound = AlarmSound.fromId(soundId);
        await _player.setAsset(sound.assetPath);
      }
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(volume);
      await _player.play();
    } catch (e) {
      try {
        await _player.setUrl(
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        );
        await _player.setLoopMode(LoopMode.one);
        await _player.setVolume(1.0);
        await _player.play();
      } catch (_) {}
    }
  }

  Future<void> stopAlarm() async {
    await _player.stop();
    if (_previousVolume != null) {
      VolumeController().setVolume(_previousVolume!);
    }
  }

  void dispose() {
    _player.dispose();
  }
}
