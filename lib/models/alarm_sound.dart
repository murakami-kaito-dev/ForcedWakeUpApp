class AlarmSound {
  final String id;
  final String displayName;
  final String assetPath;
  final bool isPremium;

  const AlarmSound({
    required this.id,
    required this.displayName,
    required this.assetPath,
    required this.isPremium,
  });

  static const List<AlarmSound> all = [
    AlarmSound(
      id: 'fanfare',
      displayName: 'ファンファーレ',
      assetPath: 'assets/sounds/fanfare.wav',
      isPremium: false,
    ),
    AlarmSound(
      id: 'freshmorning',
      displayName: '目覚めの朝',
      assetPath: 'assets/sounds/freshmorning.wav',
      isPremium: true,
    ),
    AlarmSound(
      id: 'fantasy',
      displayName: 'ファンタジー',
      assetPath: 'assets/sounds/fantasy.wav',
      isPremium: true,
    ),
  ];

  static AlarmSound fromId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);
}
