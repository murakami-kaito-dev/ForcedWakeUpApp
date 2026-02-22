class MissionLog {
  final int? id;
  final String date;
  final String missionId;
  final String result; // 'success' | 'failure'
  final int target;
  final int achieved;
  final int durationSeconds;
  final String createdAt;

  const MissionLog({
    this.id,
    required this.date,
    required this.missionId,
    required this.result,
    required this.target,
    required this.achieved,
    required this.durationSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'mission_id': missionId,
      'result': result,
      'target': target,
      'achieved': achieved,
      'duration_seconds': durationSeconds,
      'created_at': createdAt,
    };
  }

  factory MissionLog.fromMap(Map<String, dynamic> map) {
    return MissionLog(
      id: map['id'] as int?,
      date: map['date'] as String,
      missionId: map['mission_id'] as String,
      result: map['result'] as String,
      target: map['target'] as int,
      achieved: map['achieved'] as int,
      durationSeconds: map['duration_seconds'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}
