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
import '../state/language_state.dart';
import '../state/premium_state.dart';
import '../theme/app_colors.dart';

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
        final s = context.read<LanguageState>().strings;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.soundSet(displayName))),
        );
      }
    } catch (e) {
      _isPickingFile = false;
      if (mounted) {
        final s = context.read<LanguageState>().strings;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.filePickFailed)),
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
    final s = context.read<LanguageState>().strings;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          s.volumeInfoTitle,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.freePlanLabel,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.freePlanVolumeDesc,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              s.premiumPlanLabel,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.premiumPlanVolumeDesc,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              s.volumePreviewNote,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final isPremium = context.watch<PremiumState>().isPremium;
    final s = context.watch<LanguageState>().strings;
    final selectedSoundId = alarmState.settings.alarmSoundId;
    final customSoundPath = alarmState.settings.customSoundPath;
    final customSoundName = alarmState.settings.customSoundName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            Text(s.alarmSound, style: const TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      s.volume,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _showVolumeInfo,
                      child: const Icon(Icons.info_outline,
                          color: AppColors.textHint, size: 18),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Premium',
                          style:
                              TextStyle(color: AppColors.textPrimary, fontSize: 10),
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
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.textHint,
                    onChanged: _onVolumeChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.volumeMin,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      Text(s.volumeMax,
                          style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ] else ...[
                  // Free plan: show max volume indicator
                  const Slider(
                    value: 1.0,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppColors.textHint,
                    inactiveColor: AppColors.textHint,
                    onChanged: null,
                  ),
                  Text(
                    s.alarmAtMaxVolume,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            s.selectAlarmSound,
            style: const TextStyle(
                color: AppColors.textPrimary,
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
                        ? AppColors.selected
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
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
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.soundName(sound.id),
                        style: TextStyle(
                          color:
                              isLocked ? AppColors.textHint : AppColors.textPrimary,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock,
                            color: AppColors.textHint, size: 16),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _playingId == sound.id
                              ? Icons.stop
                              : Icons.play_arrow,
                          color: AppColors.textSecondary,
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
                    ? AppColors.selected
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedSoundId == 'custom'
                      ? AppColors.accent
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
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.selectFromDevice,
                          style: TextStyle(
                            color: !isPremium
                                ? AppColors.textSecondary
                                : Colors.white,
                          ),
                        ),
                        if (selectedSoundId == 'custom' &&
                            customSoundPath != null)
                          Text(
                            customSoundName ??
                                customSoundPath.split('/').last,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    const Icon(Icons.lock, color: AppColors.textHint, size: 16),
                  if (isPremium)
                    const Icon(Icons.folder_open, color: AppColors.textSecondary),
                  if (selectedSoundId == 'custom' &&
                      customSoundPath != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _playingId == 'custom'
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: AppColors.textSecondary,
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
