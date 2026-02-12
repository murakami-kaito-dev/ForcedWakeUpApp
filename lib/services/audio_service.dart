import 'package:just_audio/just_audio.dart';
import 'package:volume_controller/volume_controller.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  double? _previousVolume;

  Future<void> playAlarm() async {
    try {
      VolumeController().showSystemUI = false;
      _previousVolume = await VolumeController().getVolume();
      VolumeController().setVolume(1.0);

      await _player.setAsset('assets/sounds/alarm.wav');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      // Fallback: use a URL-based sound if asset not found
      try {
        await _player.setUrl(
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        );
        await _player.setLoopMode(LoopMode.one);
        await _player.setVolume(1.0);
        await _player.play();
      } catch (_) {
        // No sound available
      }
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
