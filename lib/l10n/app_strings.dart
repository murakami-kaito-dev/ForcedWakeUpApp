class AppStrings {
  // --- App ---
  final String appTitle;

  // --- Mission names ---
  final Map<String, String> _missionNames;
  String missionName(String id) => _missionNames[id] ?? id;

  // --- Mission category names ---
  final String categoryWorkout;
  final String categoryStudy;

  // --- Target units ---
  final String unitReps;
  final String unitSeconds;

  // --- Alarm sound names ---
  final Map<String, String> _soundNames;
  String soundName(String id) => _soundNames[id] ?? id;

  // --- Home screen ---
  final String morningMission;
  final String target;
  final String goodNight;
  final String doNotCloseApp;
  final String cancel;
  final String done;
  final String nowLabel;
  final String alarmNotInBackground;
  final String exerciseModeration;

  // --- Home: mission info ---
  final String missionInfoSquat;
  final String missionInfoPushUp;
  final String missionInfoBurpee;
  final String missionInfoReading;
  final String missionInfoStudying;

  // --- Alarm screen ---
  String alarmInstructionReading(int sec) => _alarmInstructionReadingFn(sec);
  final String Function(int) _alarmInstructionReadingFn;
  String alarmInstructionStudying(int sec) => _alarmInstructionStudyingFn(sec);
  final String Function(int) _alarmInstructionStudyingFn;
  String alarmInstructionExercise(String name, int count) =>
      _alarmInstructionExerciseFn(name, count);
  final String Function(String, int) _alarmInstructionExerciseFn;
  final String wakeUpTime;
  final String startExercise;
  final String start;
  final String brightPlace;
  final String recommendStand;

  // --- Sleep screen ---
  final String cancelAlarmTitle;
  final String cancelAlarmBody;
  final String cancelAlarmConfirm;
  final String chargeAndSleep;

  // --- Exercise screen ---
  String remainingSec(int n) => _remainingSecFn(n);
  final String Function(int) _remainingSecFn;
  String remainingReps(int n) => _remainingRepsFn(n);
  final String Function(int) _remainingRepsFn;
  final String detecting;
  final String showObjectToCamera;
  final String detectionTrouble;
  final String quitToday;

  // Exercise: skip dialog
  final String skipDetectionTitle;
  final String skipDetectionBodyWorkout;
  final String skipDetectionBodyStudy;
  final String back;
  final String markComplete;

  // Exercise: quit dialog
  final String reallyQuitTitle;
  final String reallyQuitBody;
  final String continueBtn;
  final String quitBtn;

  // --- Completion screen ---
  final String goodMorning;
  final String haveANiceDay;
  String streakDays(int n) => _streakDaysFn(n);
  final String Function(int) _streakDaysFn;
  final String share;
  final String backToHome;
  String shareText(int streak) => _shareTextFn(streak);
  final String Function(int) _shareTextFn;
  final String shareEditTitle;
  final String shareEditHint;

  // --- Failure screen ---
  final String missionFailed;
  final String tryAgainTomorrow;

  // --- Paywall screen ---
  final String unlockAll;
  final List<String> premiumFeatures;
  final String yearlyPlan;
  String yearlyPriceLabel(String price) => _yearlyPriceLabelFn(price);
  final String Function(String) _yearlyPriceLabelFn;
  String yearlySubtitle(String monthlyEquiv, int savingsPercent) =>
      _yearlySubtitleFn(monthlyEquiv, savingsPercent);
  final String Function(String, int) _yearlySubtitleFn;
  final String monthlyPlan;
  String monthlyPriceLabel(String price) => _monthlyPriceLabelFn(price);
  final String Function(String) _monthlyPriceLabelFn;
  final String recommended;
  final String subscribe;
  final String restorePurchase;
  final String redeemOfferCode;
  String purchaseFailed(String e) => _purchaseFailedFn(e);
  final String Function(String) _purchaseFailedFn;

  // --- Statistics screen ---
  final String statistics;
  final String currentStreak;
  final String bestStreak;
  final String monthlySuccessRate;
  final String monthlyAttempts;
  final String calendar;
  final String missionBreakdown;
  String daysSuffix(int n) => _daysSuffixFn(n);
  final String Function(int) _daysSuffixFn;
  String timesSuffix(int n) => _timesSuffixFn(n);
  final String Function(int) _timesSuffixFn;

  // --- Sound selection screen ---
  final String alarmSound;
  final String volume;
  final String volumeMin;
  final String volumeMax;
  final String alarmAtMaxVolume;
  final String alarmAtMaxVolumePrefix;
  final String alarmAtMaxVolumeHighlight;
  final String alarmAtMaxVolumeSuffix;
  final String selectAlarmSound;
  final String selectFromDevice;
  String soundSet(String name) => _soundSetFn(name);
  final String Function(String) _soundSetFn;
  final String filePickFailed;
  final String saveVolume;
  final String volumeSaved;
  final String zeroVolumeWarningTitle;
  final String zeroVolumeWarningBody;
  final String volumeZeroNotice;

  // Sound: volume info dialog
  final String volumeInfoTitle;
  final String freePlanLabel;
  final String freePlanVolumeDesc;
  final String premiumPlanLabel;
  final String premiumPlanVolumeDesc;
  final String volumePreviewNote;

  // --- Badge ---
  final String badgesTitle;
  final Map<String, String> _badgeNames;
  String badgeName(String id) => _badgeNames[id] ?? id;
  String badgeUnlockCondition(int days) => _badgeUnlockConditionFn(days);
  final String Function(int) _badgeUnlockConditionFn;
  final String badgeEarnedTitle;
  String badgeEarnedBody(int days) => _badgeEarnedBodyFn(days);
  final String Function(int) _badgeEarnedBodyFn;
  String badgeAnniversaryBody(int years) => _badgeAnniversaryBodyFn(years);
  final String Function(int) _badgeAnniversaryBodyFn;
  String badgeShareText(String name, int streak) =>
      _badgeShareTextFn(name, streak);
  final String Function(String, int) _badgeShareTextFn;
  String unlockedAt(String date) => _unlockedAtFn(date);
  final String Function(String) _unlockedAtFn;

  // --- Language dialog ---
  final String selectLanguageTitle;

  const AppStrings._({
    required this.appTitle,
    required Map<String, String> missionNames,
    required this.categoryWorkout,
    required this.categoryStudy,
    required this.unitReps,
    required this.unitSeconds,
    required Map<String, String> soundNames,
    required this.morningMission,
    required this.target,
    required this.goodNight,
    required this.doNotCloseApp,
    required this.cancel,
    required this.done,
    required this.nowLabel,
    required this.alarmNotInBackground,
    required this.exerciseModeration,
    required this.missionInfoSquat,
    required this.missionInfoPushUp,
    required this.missionInfoBurpee,
    required this.missionInfoReading,
    required this.missionInfoStudying,
    required String Function(int) alarmInstructionReadingFn,
    required String Function(int) alarmInstructionStudyingFn,
    required String Function(String, int) alarmInstructionExerciseFn,
    required this.wakeUpTime,
    required this.startExercise,
    required this.start,
    required this.brightPlace,
    required this.recommendStand,
    required this.cancelAlarmTitle,
    required this.cancelAlarmBody,
    required this.cancelAlarmConfirm,
    required this.chargeAndSleep,
    required String Function(int) remainingSecFn,
    required String Function(int) remainingRepsFn,
    required this.detecting,
    required this.showObjectToCamera,
    required this.detectionTrouble,
    required this.quitToday,
    required this.skipDetectionTitle,
    required this.skipDetectionBodyWorkout,
    required this.skipDetectionBodyStudy,
    required this.back,
    required this.markComplete,
    required this.reallyQuitTitle,
    required this.reallyQuitBody,
    required this.continueBtn,
    required this.quitBtn,
    required this.goodMorning,
    required this.haveANiceDay,
    required String Function(int) streakDaysFn,
    required this.share,
    required this.backToHome,
    required String Function(int) shareTextFn,
    required this.shareEditTitle,
    required this.shareEditHint,
    required this.missionFailed,
    required this.tryAgainTomorrow,
    required this.unlockAll,
    required this.premiumFeatures,
    required this.yearlyPlan,
    required String Function(String) yearlyPriceLabelFn,
    required String Function(String, int) yearlySubtitleFn,
    required this.monthlyPlan,
    required String Function(String) monthlyPriceLabelFn,
    required this.recommended,
    required this.subscribe,
    required this.restorePurchase,
    required this.redeemOfferCode,
    required String Function(String) purchaseFailedFn,
    required this.statistics,
    required this.currentStreak,
    required this.bestStreak,
    required this.monthlySuccessRate,
    required this.monthlyAttempts,
    required this.calendar,
    required this.missionBreakdown,
    required String Function(int) daysSuffixFn,
    required String Function(int) timesSuffixFn,
    required this.alarmSound,
    required this.volume,
    required this.volumeMin,
    required this.volumeMax,
    required this.alarmAtMaxVolume,
    required this.alarmAtMaxVolumePrefix,
    required this.alarmAtMaxVolumeHighlight,
    required this.alarmAtMaxVolumeSuffix,
    required this.selectAlarmSound,
    required this.selectFromDevice,
    required String Function(String) soundSetFn,
    required this.filePickFailed,
    required this.saveVolume,
    required this.volumeSaved,
    required this.zeroVolumeWarningTitle,
    required this.zeroVolumeWarningBody,
    required this.volumeZeroNotice,
    required this.volumeInfoTitle,
    required this.freePlanLabel,
    required this.freePlanVolumeDesc,
    required this.premiumPlanLabel,
    required this.premiumPlanVolumeDesc,
    required this.volumePreviewNote,
    required Map<String, String> badgeNames,
    required this.badgesTitle,
    required String Function(int) badgeUnlockConditionFn,
    required this.badgeEarnedTitle,
    required String Function(int) badgeEarnedBodyFn,
    required String Function(int) badgeAnniversaryBodyFn,
    required String Function(String, int) badgeShareTextFn,
    required String Function(String) unlockedAtFn,
    required this.selectLanguageTitle,
  })  : _badgeNames = badgeNames,
        _badgeUnlockConditionFn = badgeUnlockConditionFn,
        _badgeEarnedBodyFn = badgeEarnedBodyFn,
        _badgeAnniversaryBodyFn = badgeAnniversaryBodyFn,
        _badgeShareTextFn = badgeShareTextFn,
        _unlockedAtFn = unlockedAtFn,
        _missionNames = missionNames,
        _soundNames = soundNames,
        _alarmInstructionReadingFn = alarmInstructionReadingFn,
        _alarmInstructionStudyingFn = alarmInstructionStudyingFn,
        _alarmInstructionExerciseFn = alarmInstructionExerciseFn,
        _remainingSecFn = remainingSecFn,
        _remainingRepsFn = remainingRepsFn,
        _streakDaysFn = streakDaysFn,
        _shareTextFn = shareTextFn,
        _purchaseFailedFn = purchaseFailedFn,
        _yearlyPriceLabelFn = yearlyPriceLabelFn,
        _yearlySubtitleFn = yearlySubtitleFn,
        _monthlyPriceLabelFn = monthlyPriceLabelFn,
        _daysSuffixFn = daysSuffixFn,
        _timesSuffixFn = timesSuffixFn,
        _soundSetFn = soundSetFn;

  static final ja = AppStrings._(
    appTitle: 'モーニングルーティン\n強制アラーム',
    missionNames: {
      'squat': 'スクワット',
      'pushUp': '腕立て伏せ',
      'burpee': 'バーピー',
      'reading': '読書',
      'studying': '勉強',
    },
    categoryWorkout: '運動',
    categoryStudy: '勉強',
    unitReps: '回',
    unitSeconds: '秒',
    soundNames: {
      'fanfare': 'ファンファーレ',
      'freshmorning': '目覚めの朝',
      'fantasy': 'ファンタジー',
    },
    morningMission: 'モーニングミッション',
    target: '目標',
    goodNight: 'おやすみ',
    doNotCloseApp: 'アプリを閉じないでください',
    cancel: 'キャンセル',
    done: '設定',
    nowLabel: '現在時刻',
    alarmNotInBackground: 'バックグラウンドではアラームが鳴りません',
    exerciseModeration:
        '無理のない、目が覚めるくらいの回数に設定してください。\n朝から無理のある運動はかえって良くないですからね。',
    missionInfoSquat:
        'カメラの前でスクワットをしてください。\n\n全身が映るようにスマホを置き、膝の曲げ伸ばしが検出されると1回カウントされます。',
    missionInfoPushUp:
        'カメラの前で腕立て伏せをしてください。\n\n上半身が映るようにスマホを置き、腕の曲げ伸ばしが検出されると1回カウントされます。',
    missionInfoBurpee:
        'カメラの前でバーピーをしてください。\n\n全身が映るようにスマホを置き、しゃがむ→伏せる→立ち上がるの動作が検出されると1回カウントされます。',
    missionInfoReading:
        '本や参考書をカメラに映してください。\n\n背面カメラで本を映し続けると、検出されている間タイマーが進みます。',
    missionInfoStudying:
        'ペンをカメラに映してください。\n\n背面カメラでペンなどの文房具を映すと、検出されている間タイマーが進みます。',
    alarmInstructionReadingFn: _jaAlarmReading,
    alarmInstructionStudyingFn: _jaAlarmStudying,
    alarmInstructionExerciseFn: _jaAlarmExercise,
    wakeUpTime: '起きる時間です！',
    startExercise: '運動を始める',
    start: '始める',
    brightPlace: '明るい場所で行ってください',
    recommendStand: 'スマホスタンドの使用を推奨します',
    cancelAlarmTitle: 'アラームを解除しますか？',
    cancelAlarmBody: 'ホーム画面に戻ります。',
    cancelAlarmConfirm: '解除する',
    chargeAndSleep: '充電しておやすみください',
    remainingSecFn: _jaRemainingSec,
    remainingRepsFn: _jaRemainingReps,
    detecting: '検出中...',
    showObjectToCamera: '対象物をカメラに映してください',
    detectionTrouble: 'うまく検知できない場合',
    quitToday: '今日はやめる',
    skipDetectionTitle: '検知をスキップしますか？',
    skipDetectionBodyWorkout: '実際に運動をしているのに検知されない場合、今日は達成扱いにできます。',
    skipDetectionBodyStudy: '実際に本やペンを用意しているのに検知されない場合、今日は達成扱いにできます。',
    back: '戻る',
    markComplete: '達成にする',
    reallyQuitTitle: '本当にやめますか？',
    reallyQuitBody: 'アラームを停止してホーム画面に戻ります。',
    continueBtn: '続ける',
    quitBtn: 'やめる',
    goodMorning: 'おはようございます！',
    haveANiceDay: '素晴らしい！今日も良い一日を。',
    streakDaysFn: _jaStreakDays,
    share: 'シェアする',
    backToHome: 'ホームに戻る',
    shareTextFn: _jaShareText,
    shareEditTitle: 'シェア内容を編集',
    shareEditHint: 'シェアしたいメッセージを入力...',
    missionFailed: 'ミッション未達成',
    tryAgainTomorrow: 'また明日チャレンジしましょう！',
    unlockAll: '全ての機能をアンロック',
    premiumFeatures: [
      '読書・勉強ミッション', // バーピー・読書・勉強ミッション // 新バージョンで表示変更する
      'アラーム音の選択',
      '達成統計・連続記録',
      'SNSシェア機能',
    ],
    yearlyPlan: '年額プラン',
    yearlyPriceLabelFn: (price) => '$price / 年',
    yearlySubtitleFn: (monthlyEquiv, pct) =>
        '7日間の無料トライアル付き（月額換算 約$monthlyEquiv・$pct%お得）',
    monthlyPlan: '月額プラン',
    monthlyPriceLabelFn: (price) => '$price / 月',
    recommended: 'おすすめ',
    subscribe: 'サブスクリプションを購入する',
    restorePurchase: '購入を復元',
    redeemOfferCode: 'プロモーションコードを入力',
    purchaseFailedFn: _jaPurchaseFailed,
    statistics: '統計',
    currentStreak: '連続記録',
    bestStreak: '最長記録',
    monthlySuccessRate: '今月の成功率',
    monthlyAttempts: '今月の試行回数',
    calendar: 'カレンダー',
    missionBreakdown: 'ミッション別実績',
    daysSuffixFn: _jaDays,
    timesSuffixFn: _jaTimes,
    alarmSound: 'アラーム音',
    volume: '音量',
    volumeMin: '小',
    volumeMax: '大',
    alarmAtMaxVolume: 'アラームは最大音量で鳴ります',
    alarmAtMaxVolumePrefix: 'アラームは',
    alarmAtMaxVolumeHighlight: '最大音量',
    alarmAtMaxVolumeSuffix: 'で鳴ります',
    selectAlarmSound: 'アラーム音を選択',
    selectFromDevice: '端末から選択',
    soundSetFn: _jaSoundSet,
    filePickFailed: 'ファイルの選択に失敗しました',
    saveVolume: 'この音量で保存',
    volumeSaved: 'アラーム音量を保存しました',
    zeroVolumeWarningTitle: '音量がゼロです',
    zeroVolumeWarningBody: 'アラームの音が鳴りません。このまま保存しますか？',
    volumeZeroNotice: '音量ゼロ：アラーム音が鳴りません',
    volumeInfoTitle: 'アラーム音量について',
    freePlanLabel: '無料プラン',
    freePlanVolumeDesc: 'アラームは常に最大音量で鳴ります。確実に起きるための仕様です。',
    premiumPlanLabel: 'Premiumプラン',
    premiumPlanVolumeDesc: 'お好みの音量に調整できます。設定した音量でアラームが鳴ります。',
    volumePreviewNote: '※ 試聴はデバイスの現在の音量で再生されます。',
    badgeNames: {
      'day1': 'はじめの一歩',
      'day3': '芽生え',
      'day7': 'スタートダッシュ',
      'day14': 'ルーティン',
      'day21': '習慣化',
      'day28': '4週間達成',
      'day30': '1ヶ月達成',
      'day40': '加速',
      'day50': 'マスター',
      'day60': '情熱',
      'day70': '鉄壁',
      'day80': 'ロケット',
      'day90': '3ヶ月達成',
      'day100': 'レジェンド',
      'day125': 'きらめき',
      'day150': '栄光',
      'day175': '閃光',
      'day200': '200日の軌跡',
      'day300': '城塞',
      'day365': '1年達成',
      'day400': 'グローバル',
      'day500': '大地',
      'day600': 'フレア',
      'day700': '夜明け',
      'day730': '2年達成',
      'day800': 'サイクロン',
      'day900': '火山',
      'day1000': '無限',
      'day1095': '3年達成',
      'day1100': '輝き',
    },
    badgesTitle: '達成バッジ',
    badgeUnlockConditionFn: _jaBadgeUnlockCondition,
    badgeEarnedTitle: 'おめでとう！',
    badgeEarnedBodyFn: _jaBadgeEarnedBody,
    badgeAnniversaryBodyFn: _jaBadgeAnniversaryBody,
    badgeShareTextFn: _jaBadgeShareText,
    unlockedAtFn: _jaUnlockedAt,
    selectLanguageTitle: '言語を選択 / Select Language',
  );

  static final en = AppStrings._(
    appTitle: 'ForcedWake Alarm',
    missionNames: {
      'squat': 'Squats',
      'pushUp': 'Push-ups',
      'burpee': 'Burpees',
      'reading': 'Reading',
      'studying': 'Studying',
    },
    categoryWorkout: 'Workout',
    categoryStudy: 'Study',
    unitReps: 'reps',
    unitSeconds: 'sec',
    soundNames: {
      'fanfare': 'Fanfare',
      'freshmorning': 'Fresh Morning',
      'fantasy': 'Fantasy',
    },
    morningMission: 'Morning Mission',
    target: 'Target',
    goodNight: 'Good Night',
    doNotCloseApp: 'Please do not close the app',
    cancel: 'Cancel',
    done: 'Done',
    nowLabel: 'Now',
    alarmNotInBackground: 'The alarm will not ring in the background',
    exerciseModeration:
        "Set a manageable number — just enough to wake you up.\nOverdoing it first thing in the morning isn't good for you.",
    missionInfoSquat:
        'Do squats in front of the camera.\n\nPlace your phone so your full body is visible. Each knee bend is counted as one rep.',
    missionInfoPushUp:
        'Do push-ups in front of the camera.\n\nPlace your phone so your upper body is visible. Each arm bend is counted as one rep.',
    missionInfoBurpee:
        'Do burpees in front of the camera.\n\nPlace your phone so your full body is visible. Each squat-down, push-up, stand-up cycle counts as one rep.',
    missionInfoReading:
        'Point the camera at a book.\n\nUse the rear camera to film a book. The timer advances while the book is detected.',
    missionInfoStudying:
        'Point the camera at a pen.\n\nUse the rear camera to film a pen or stationery. The timer advances while detected.',
    alarmInstructionReadingFn: _enAlarmReading,
    alarmInstructionStudyingFn: _enAlarmStudying,
    alarmInstructionExerciseFn: _enAlarmExercise,
    wakeUpTime: "Time to wake up!",
    startExercise: 'Start Exercise',
    start: 'Start',
    brightPlace: 'Use a well-lit area',
    recommendStand: 'A phone stand is recommended',
    cancelAlarmTitle: 'Cancel the alarm?',
    cancelAlarmBody: 'You will return to the home screen.',
    cancelAlarmConfirm: 'Cancel Alarm',
    chargeAndSleep: 'Charge your phone and sleep well',
    remainingSecFn: _enRemainingSec,
    remainingRepsFn: _enRemainingReps,
    detecting: 'Detecting...',
    showObjectToCamera: 'Show the object to the camera',
    detectionTrouble: 'Detection not working?',
    quitToday: 'Quit for today',
    skipDetectionTitle: 'Skip detection?',
    skipDetectionBodyWorkout:
        "If you're exercising but detection isn't working, you can mark today as complete.",
    skipDetectionBodyStudy:
        "If you have the book or pen ready but detection isn't working, you can mark today as complete.",
    back: 'Back',
    markComplete: 'Mark Complete',
    reallyQuitTitle: 'Are you sure?',
    reallyQuitBody:
        'The alarm will stop and you will return to the home screen.',
    continueBtn: 'Continue',
    quitBtn: 'Quit',
    goodMorning: 'Good morning!',
    haveANiceDay: "Great job! Have a wonderful day.",
    streakDaysFn: _enStreakDays,
    share: 'Share',
    backToHome: 'Back to Home',
    shareTextFn: _enShareText,
    shareEditTitle: 'Edit Share Message',
    shareEditHint: 'Enter a message to share...',
    missionFailed: 'Mission Incomplete',
    tryAgainTomorrow: 'Try again tomorrow!',
    unlockAll: 'Unlock all features',
    premiumFeatures: [
      'Reading & Study missions', // Burpees, Reading & Study missions // 新バージョンで表示変更する
      'Alarm sound selection',
      'Achievement stats & streaks',
      'Social sharing',
    ],
    yearlyPlan: 'Yearly Plan',
    yearlyPriceLabelFn: (price) => '$price / year',
    yearlySubtitleFn: (monthlyEquiv, pct) =>
        '7-day free trial included ($monthlyEquiv/mo · Save $pct%)',
    monthlyPlan: 'Monthly Plan',
    monthlyPriceLabelFn: (price) => '$price / month',
    recommended: 'Best Value',
    subscribe: 'Subscribe',
    restorePurchase: 'Restore Purchase',
    redeemOfferCode: 'Redeem Offer Code',
    purchaseFailedFn: _enPurchaseFailed,
    statistics: 'Statistics',
    currentStreak: 'Current Streak',
    bestStreak: 'Best Streak',
    monthlySuccessRate: 'Monthly Success Rate',
    monthlyAttempts: 'Monthly Attempts',
    calendar: 'Calendar',
    missionBreakdown: 'Mission Breakdown',
    daysSuffixFn: _enDays,
    timesSuffixFn: _enTimes,
    alarmSound: 'Alarm Sound',
    volume: 'Volume',
    volumeMin: 'Low',
    volumeMax: 'High',
    alarmAtMaxVolume: 'Alarm plays at max volume',
    alarmAtMaxVolumePrefix: 'Alarm plays at ',
    alarmAtMaxVolumeHighlight: 'max volume',
    alarmAtMaxVolumeSuffix: '',
    selectAlarmSound: 'Select Alarm Sound',
    selectFromDevice: 'Select from Device',
    soundSetFn: _enSoundSet,
    filePickFailed: 'Failed to select file',
    saveVolume: 'Save Volume',
    volumeSaved: 'Alarm volume saved',
    zeroVolumeWarningTitle: 'Volume is zero',
    zeroVolumeWarningBody: 'The alarm will not make any sound. Save anyway?',
    volumeZeroNotice: 'Volume is zero: alarm will be silent',
    volumeInfoTitle: 'About Alarm Volume',
    freePlanLabel: 'Free Plan',
    freePlanVolumeDesc:
        'The alarm always plays at maximum volume to make sure you wake up.',
    premiumPlanLabel: 'Premium Plan',
    premiumPlanVolumeDesc:
        'Adjust the volume to your preference. The alarm plays at your set volume.',
    volumePreviewNote: '* Preview plays at your current device volume.',
    badgeNames: {
      'day1': 'First Step',
      'day3': 'Sprout',
      'day7': 'Start Dash',
      'day14': 'Routine',
      'day21': 'Habit Formed',
      'day28': '4 Weeks',
      'day30': '1 Month',
      'day40': 'Accelerate',
      'day50': 'Master',
      'day60': 'Passion',
      'day70': 'Iron Wall',
      'day80': 'Rocket',
      'day90': '3 Months',
      'day100': 'Legend',
      'day125': 'Sparkle',
      'day150': 'Glory',
      'day175': 'Flash',
      'day200': '200-Day Journey',
      'day300': 'Fortress',
      'day365': '1 Year',
      'day400': 'Global',
      'day500': 'Terrain',
      'day600': 'Flare',
      'day700': 'Daybreak',
      'day730': '2 Years',
      'day800': 'Cyclone',
      'day900': 'Volcano',
      'day1000': 'Infinity',
      'day1095': '3 Years',
      'day1100': 'Radiance',
    },
    badgesTitle: 'Achievement Badges',
    badgeUnlockConditionFn: _enBadgeUnlockCondition,
    badgeEarnedTitle: 'Congratulations!',
    badgeEarnedBodyFn: _enBadgeEarnedBody,
    badgeAnniversaryBodyFn: _enBadgeAnniversaryBody,
    badgeShareTextFn: _enBadgeShareText,
    unlockedAtFn: _enUnlockedAt,
    selectLanguageTitle: '言語を選択 / Select Language',
  );

  // --- Japanese dynamic strings ---
  static String _jaAlarmReading(int sec) => '本や参考書を$sec秒カメラに映してアラームを解除';
  static String _jaAlarmStudying(int sec) => 'ペンを$sec秒カメラに映してアラームを解除';
  static String _jaAlarmExercise(String name, int count) =>
      '$nameを$count回行ってアラームを解除';
  static String _jaRemainingSec(int n) => '残り $n 秒';
  static String _jaRemainingReps(int n) => '残り $n 回';
  static String _jaStreakDays(int n) => '$n日連続';
  static String _jaShareText(int streak) =>
      'モーニングルーティン強制アラームで$streak日連続起床達成！運動しないと止まらないアラームで朝活を継続中！';
  static String _jaPurchaseFailed(String e) => '購入に失敗しました';
  static String _jaDays(int n) => '$n日';
  static String _jaTimes(int n) => '$n回';
  static String _jaSoundSet(String name) => '$name を設定しました';
  static String _jaBadgeUnlockCondition(int days) => '$days日連続で解放';
  static String _jaBadgeEarnedBody(int days) => '$days日連続達成しました！';
  static String _jaBadgeAnniversaryBody(int years) => '$years年達成しました！';
  static String _jaBadgeShareText(String name, int streak) =>
      'モーニングルーティン強制アラームで「$name」バッジを獲得！$streak日連続起床達成！';
  static String _jaUnlockedAt(String date) => '$date 獲得';

  // --- English dynamic strings ---
  static String _enAlarmReading(int sec) =>
      'Show a book to the camera for $sec seconds to dismiss';
  static String _enAlarmStudying(int sec) =>
      'Show a pen to the camera for $sec seconds to dismiss';
  static String _enAlarmExercise(String name, int count) =>
      'Do $count $name to dismiss the alarm';
  static String _enRemainingSec(int n) => '$n sec left';
  static String _enRemainingReps(int n) => '$n reps left';
  static String _enStreakDays(int n) => '$n-day streak';
  static String _enShareText(int streak) =>
      "I've woken up $streak days in a row with ForcedWake Alarm! An alarm that won't stop until you exercise.";
  static String _enPurchaseFailed(String e) => 'Purchase failed';
  static String _enDays(int n) => '$n days';
  static String _enTimes(int n) => '$n times';
  static String _enSoundSet(String name) => '$name has been set';
  static String _enBadgeUnlockCondition(int days) =>
      'Unlocks at $days-day streak';
  static String _enBadgeEarnedBody(int days) =>
      'You achieved a $days-day streak!';
  static String _enBadgeAnniversaryBody(int years) =>
      'You achieved $years year${years > 1 ? 's' : ''}!';
  static String _enBadgeShareText(String name, int streak) =>
      'I earned the "$name" badge on ForcedWake Alarm! $streak-day streak!';
  static String _enUnlockedAt(String date) => 'Earned $date';

  String missionInfo(String id) {
    switch (id) {
      case 'squat':
        return missionInfoSquat;
      case 'pushUp':
        return missionInfoPushUp;
      case 'burpee':
        return missionInfoBurpee;
      case 'reading':
        return missionInfoReading;
      case 'studying':
        return missionInfoStudying;
      default:
        return '';
    }
  }
}
