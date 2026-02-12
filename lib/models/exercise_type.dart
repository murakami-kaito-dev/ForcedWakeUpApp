enum ExerciseType {
  squat,
  pushUp;

  String get displayName {
    switch (this) {
      case ExerciseType.squat:
        return 'スクワット';
      case ExerciseType.pushUp:
        return '腕立て伏せ';
    }
  }
}
