import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import '../models/alarm_sound.dart';
import '../state/alarm_state.dart';
import '../state/premium_state.dart';

class SoundSelectionScreen extends StatefulWidget {
  const SoundSelectionScreen({super.key});

  @override
  State<SoundSelectionScreen> createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen>
    with WidgetsBindingObserver {
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _playingId;
  double _deviceVolume = 1.0;
  StreamSubscription<double>? _volumeSubscription;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVolumeListener();
  }

  Future<void> _initVolumeListener() async {
    try {
      VolumeController().showSystemUI = true;
      final vol = await VolumeController().getVolume();
      if (mounted) {
        setState(() => _deviceVolume = vol.clamp(0.0, 1.0));
      }

      if (!mounted) return;
      final isPremium = context.read<PremiumState>().isPremium;
      if (isPremium) {
        // Premium: sync slider with device volume buttons
        _volumeSubscription = VolumeController().listener((volume) {
          if (mounted) {
            setState(() => _deviceVolume = volume.clamp(0.0, 1.0));
            context
                .read<AlarmState>()
                .updateAlarmVolume(volume.clamp(0.3, 1.0));
          }
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPickingFile) {
      _isPickingFile = false;
    }
    // Stop preview when device sleeps or app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_playingId != null) {
        _previewPlayer.stop();
        setState(() => _playingId = null);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _volumeSubscription?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _stopPreview() async {
    await _previewPlayer.stop();
    setState(() => _playingId = null);
  }

  Future<void> _startPreview(String id) async {
    setState(() => _playingId = id);
    await _previewPlayer.setVolume(_deviceVolume);
    await _previewPlayer.setLoopMode(LoopMode.one);
    await _previewPlayer.seek(Duration.zero);
    unawaited(_previewPlayer.play());
  }

  Future<void> _playPreview(AlarmSound sound) async {
    if (_playingId == sound.id) {
      await _stopPreview();
      return;
    }

    try {
      await _stopPreview();
      await _previewPlayer.setAsset(sound.assetPath);
      await _startPreview(sound.id);
    } catch (_) {}
  }

  Future<String?> _resolveCustomSoundPath(String storedPath) async {
    if (await File(storedPath).exists()) return storedPath;
    final fileName = p.basename(storedPath);
    final appDir = await getApplicationDocumentsDirectory();
    final resolvedPath = '${appDir.path}/$fileName';
    if (await File(resolvedPath).exists()) return resolvedPath;
    return null;
  }

  Future<void> _playCustomPreview(String path) async {
    if (_playingId == 'custom') {
      await _stopPreview();
      return;
    }

    try {
      final resolvedPath = await _resolveCustomSoundPath(path);
      if (resolvedPath == null) return;
      await _stopPreview();
      await _previewPlayer.setFilePath(resolvedPath);
      await _startPreview('custom');
    } catch (_) {}
  }

  Future<void> _pickCustomSound() async {
    _isPickingFile = true;
    try {
      await _previewPlayer.stop();
      setState(() => _playingId = null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (!mounted) return;
      _isPickingFile = false;

      if (result == null || result.files.single.path == null) return;

      final srcPath = result.files.single.path!;
      final originalName = result.files.single.name;

      // Display name without extension
      final displayName = originalName.contains('.')
          ? originalName.substring(0, originalName.lastIndexOf('.'))
          : originalName;

      final ext = originalName.contains('.')
          ? '.${originalName.split('.').last}'
          : '';
      final safeName =
          'custom_alarm_${DateTime.now().millisecondsSinceEpoch}$ext';

      final appDir = await getApplicationDocumentsDirectory();
      final destPath = '${appDir.path}/$safeName';

      final bytes = await File(srcPath).readAsBytes();
      await File(destPath).writeAsBytes(bytes);

      if (!mounted) return;
      final alarmState = context.read<AlarmState>();
      await alarmState.updateCustomSound(destPath, name: displayName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$displayName を設定しました')),
        );
      }
    } catch (e) {
      _isPickingFile = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ファイルの選択に失敗しました')),
        );
      }
    }
  }

  void _onVolumeChanged(double value) {
    setState(() => _deviceVolume = value);
    VolumeController().setVolume(value);
    context.read<AlarmState>().updateAlarmVolume(value.clamp(0.3, 1.0));
  }

  void _showVolumeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'アラーム音量について',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '無料プラン',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'アラームは常に最大音量で鳴ります。確実に起きるための仕様です。',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Premiumプラン',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'お好みの音量に調整できます。設定した音量でアラームが鳴ります。',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '※ 試聴はデバイスの現在の音量で再生されます。',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF533483))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final isPremium = context.watch<PremiumState>().isPremium;
    final selectedSoundId = alarmState.settings.alarmSoundId;
    final customSoundPath = alarmState.settings.customSoundPath;
    final customSoundName = alarmState.settings.customSoundName;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text('アラーム音', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Volume section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '音量',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _showVolumeInfo,
                      child: Icon(Icons.info_outline,
                          color: Colors.grey[500], size: 18),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF533483),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium',
                          style:
                              TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (isPremium) ...[
                  Slider(
                    value: _deviceVolume.clamp(0.0, 1.0),
                    min: 0.0,
                    max: 1.0,
                    activeColor: const Color(0xFF533483),
                    inactiveColor: Colors.white24,
                    onChanged: _onVolumeChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('小',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('大',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ] else ...[
                  // Free plan: show max volume indicator
                  Slider(
                    value: 1.0,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.grey[700],
                    inactiveColor: Colors.white24,
                    onChanged: null,
                  ),
                  Text(
                    'アラームは最大音量で鳴ります',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'アラーム音を選択',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Preset sounds
          ...AlarmSound.all.map((sound) {
            final isSelected = selectedSoundId == sound.id;
            final isLocked = sound.isPremium && !isPremium;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  if (isLocked) {
                    Navigator.pushNamed(context, '/paywall');
                    return;
                  }
                  alarmState.updateAlarmSound(sound.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F3460)
                        : const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF533483)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFF533483)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sound.displayName,
                        style: TextStyle(
                          color:
                              isLocked ? Colors.grey[600] : Colors.white,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock,
                            color: Colors.grey, size: 16),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _playingId == sound.id
                              ? Icons.stop
                              : Icons.play_arrow,
                          color: Colors.white70,
                        ),
                        onPressed: () => _playPreview(sound),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Custom sound option (Premium)
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (!isPremium) {
                Navigator.pushNamed(context, '/paywall');
                return;
              }
              _pickCustomSound();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedSoundId == 'custom'
                    ? const Color(0xFF0F3460)
                    : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedSoundId == 'custom'
                      ? const Color(0xFF533483)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedSoundId == 'custom'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selectedSoundId == 'custom'
                        ? const Color(0xFF533483)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '端末から選択',
                          style: TextStyle(
                            color: !isPremium
                                ? Colors.grey[600]
                                : Colors.white,
                          ),
                        ),
                        if (selectedSoundId == 'custom' &&
                            customSoundPath != null)
                          Text(
                            customSoundName ??
                                customSoundPath.split('/').last,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    const Icon(Icons.lock, color: Colors.grey, size: 16),
                  if (isPremium)
                    const Icon(Icons.folder_open, color: Colors.white70),
                  if (selectedSoundId == 'custom' &&
                      customSoundPath != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _playingId == 'custom'
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          _playCustomPreview(customSoundPath),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
