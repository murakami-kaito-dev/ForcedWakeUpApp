# 朝型強制変換アラーム — 技術ドキュメント

## 1. プロジェクト概要

カメラによるポーズ推定（ML Kit）で筋トレ（スクワット/腕立て伏せ）を検出し、規定回数を達成しないとアラームが止まらないiOSアプリ。

| 項目 | 内容 |
|---|---|
| フレームワーク | Flutter 3.24.3+ |
| 言語 | Dart |
| 対象プラットフォーム | iOS |
| 状態管理 | Provider（ChangeNotifier） |
| 現在のフェーズ | MVP |

---

## 2. アーキテクチャ

### 2.1 全体構成

**レイヤードアーキテクチャ**を採用している。責務ごとに以下の4層に分離：

```
┌─────────────────────────────────────┐
│           Screens（UI層）            │  ← ユーザーが直接触れる画面
├─────────────────────────────────────┤
│          Widgets（UI部品層）          │  ← 再利用可能なUI部品
├─────────────────────────────────────┤
│     State / Services（ビジネス層）     │  ← 状態管理・外部サービス連携
├─────────────────────────────────────┤
│     Models / Utils（データ・ロジック層） │  ← データ定義・純粋なロジック
└─────────────────────────────────────┘
```

### 2.2 デザインパターン

| パターン | 使用箇所 | 説明 |
|---|---|---|
| **Provider パターン** | `AlarmState` | 画面間で共有する状態を `ChangeNotifier` で管理し、`context.watch` / `context.read` でアクセス |
| **サービスパターン** | `AudioService`, `StorageService`, `PoseDetectionService` | 外部リソース（音声・ストレージ・ML Kit）へのアクセスをクラスに隔離 |
| **ステートマシン** | `ExerciseDetector` | 筋トレの回数カウントを状態遷移（立位→しゃがみ→立位）で管理 |
| **CustomPainter** | `PosePainter` | カメラプレビュー上に骨格を描画するためのFlutter標準パターン |

### 2.3 画面遷移フロー

全て `Navigator.pushReplacementNamed` を使用（戻る操作を禁止）。

```
Home ──(おやすみ)──→ Sleep ──(時刻到達)──→ Alarm ──(筋トレ開始)──→ Exercise ──(10回達成)──→ Completion
  ↑                                         │                                                │
  │                                         │(10分自動停止)                                    │
  └─────────────────────────────────────────┘────────────────────────────────────────(ホームへ)─┘
```

---

## 3. ディレクトリ構成

```
lib/
├── main.dart                        # エントリポイント。SharedPreferences初期化、Provider設定
├── app.dart                         # MaterialApp定義。テーマ設定、ルーティング（5画面）
│
├── models/                          # データ定義（純粋なDartクラス、依存なし）
│   ├── alarm_settings.dart          #   アラーム設定（時刻・種目・ON/OFF）+ JSON変換
│   └── exercise_type.dart           #   ExerciseType enum（squat / pushUp）
│
├── screens/                         # 画面（StatelessWidget / StatefulWidget）
│   ├── home_screen.dart             #   ホーム画面：時刻ピッカー、種目選択、おやすみボタン
│   ├── sleep_screen.dart            #   スリープ画面：暗転、カウントダウン、wakelock
│   ├── alarm_screen.dart            #   アラーム発動画面：音再生、パルスアニメ、10分自動停止
│   ├── exercise_screen.dart         #   筋トレ検出画面：カメラ+ML Kit+回数表示+骨格描画
│   └── completion_screen.dart       #   完了画面：おはようメッセージ、ホームへ戻る
│
├── services/                        # 外部リソースとのやりとり
│   ├── audio_service.dart           #   アラーム音再生（just_audio）、音量最大化（volume_controller）
│   ├── storage_service.dart         #   SharedPreferencesへの設定読み書き
│   └── pose_detection_service.dart  #   ML Kit PoseDetectorのラッパー
│
├── state/                           # 状態管理
│   └── alarm_state.dart             #   ChangeNotifier。アラーム設定・鳴動状態・回数を保持
│
├── utils/                           # 純粋なロジック（UIに依存しない）
│   ├── angle_calculator.dart        #   3点間の角度計算（atan2）
│   ├── exercise_detector.dart       #   スクワット/腕立ての回数カウント（ステートマシン）
│   └── camera_helper.dart           #   CameraImage → ML Kit InputImage 変換
│
└── widgets/                         # 再利用可能なUI部品
    └── pose_painter.dart            #   CustomPainter：骨格のリアルタイム描画

assets/
└── sounds/
    └── alarm.wav                    # アラーム音素材

ios/
└── Runner/
    └── Info.plist                   # カメラ権限(NSCameraUsageDescription)、audioバックグラウンドモード

docs/
└── ARCHITECTURE.md                  # 本ドキュメント
```

---

## 4. 主要ロジックの解説

### 4.1 ポーズ検出による筋トレカウント（exercise_detector.dart）

このアプリの最も複雑なロジック。ML Kitが検出した体の関節座標から角度を計算し、状態遷移で回数を数える。

#### 角度計算

`angle_calculator.dart` で3点（A, B, C）の角度を算出する。Bが頂点。

```
    A
   /
  B ← この角度を計算（0〜180度）
   \
    C
```

`atan2` を使って計算し、0〜180度に正規化して返す。

#### スクワット検出

使用する関節: **股関節(Hip)** → **膝(Knee)** → **足首(Ankle)**

```
状態遷移:
  [立っている]  膝角度 > 160°
       │
       │  膝角度が100°を下回る
       ▼
  [しゃがんでいる]  膝角度 < 100°
       │
       │  膝角度が160°を上回る → 1回カウント！
       ▼
  [立っている]  膝角度 > 160°
       │
       │  （繰り返し）
```

#### 腕立て伏せ検出

使用する関節: **肩(Shoulder)** → **肘(Elbow)** → **手首(Wrist)**

```
状態遷移:
  [腕を伸ばしている]  肘角度 > 160°
       │
       │  肘角度が90°を下回る
       ▼
  [腕を曲げている]  肘角度 < 90°
       │
       │  肘角度が160°を上回る → 1回カウント！
       ▼
  [腕を伸ばしている]  肘角度 > 160°
```

#### 精度向上の工夫

- **左右平均**: 左膝と右膝（または左肘と右肘）の角度を平均する。片方しか見えない場合は見えている方を使用
- **デバウンス**: 連続カウント防止のため、1回カウント後500ms間は次のカウントをしない
- **閾値**: `exercise_detector.dart` の定数を調整することでチューニング可能

```dart
static const _squatDownThreshold = 100.0;   // これ以下でしゃがみ判定
static const _squatUpThreshold = 160.0;     // これ以上で立ち判定
static const _pushUpDownThreshold = 90.0;   // これ以下で腕曲げ判定
static const _pushUpUpThreshold = 160.0;    // これ以上で腕伸ばし判定
static const _debounceMs = 500;             // カウント間隔（ミリ秒）
```

### 4.2 カメラ映像 → ML Kit 入力変換（camera_helper.dart）

iOSのカメラは `bgra8888` 形式で映像フレームを出力する。ML Kit の `InputImage` に変換する際、以下を正しく設定する必要がある：

- **format**: `InputImageFormat.bgra8888`（iOS固定）
- **bytesPerRow**: カメラプレーンから取得
- **rotation**: カメラのセンサー角度から変換

### 4.3 フレーム処理のスロットリング（exercise_screen.dart）

ML Kitのポーズ推定は1フレームごとに数十ミリ秒かかる。全フレームを処理するとメモリ不足やUIカクつきが発生するため、`_isProcessing` フラグで1フレームずつ順次処理する：

```
フレーム1 → 処理開始 → フレーム2（スキップ）→ フレーム3（スキップ）→ 処理完了 → フレーム4 → 処理開始 → ...
```

### 4.4 骨格描画の座標変換（pose_painter.dart）

ML Kitが返すランドマーク座標は「カメラ画像上のピクセル座標」。画面上に描画するには：

1. カメラ画像サイズ → 画面サイズへのスケーリング
2. フロントカメラのミラーリング（X座標を反転）

### 4.5 日付跨ぎのアラーム時刻計算（sleep_screen.dart）

23:00に「6:00のアラーム」を設定した場合、翌日の6:00として計算する必要がある。アラーム時刻が現在時刻より前であれば1日加算する。

---

## 5. 使用パッケージ一覧

| パッケージ | 用途 |
|---|---|
| `camera` | カメラ制御（フロントカメラからの映像ストリーム取得） |
| `google_mlkit_pose_detection` | ポーズ推定（体の関節座標を検出） |
| `just_audio` | アラーム音のループ再生 |
| `volume_controller` | デバイスの音量を最大に設定 |
| `shared_preferences` | アラーム設定のローカル保存 |
| `provider` | 状態管理（ChangeNotifier + Consumer） |
| `wakelock_plus` | スリープ画面で画面消灯を防止 |

---

## 6. iOS固有の設定

### Info.plist

| キー | 値 | 理由 |
|---|---|---|
| `NSCameraUsageDescription` | カメラ使用の説明文 | カメラアクセス許可ダイアログ |
| `UIBackgroundModes` | `audio` | アラーム音がバックグラウンドで一瞬途切れないため |

### Podfile

- `platform :ios, '15.5'` — google_mlkit_pose_detectionの最低要件

---

## 7. MVP未実装事項（将来の開発タスク）

| 項目 | 優先度 | 補足 |
|---|---|---|
| 複数アラーム対応 | 中 | 現在は1つのアラームのみ |
| 筋トレ回数のカスタマイズ | 中 | 現在は10回固定 |
| 筋トレ種目の追加 | 低 | ランニングウェアに着替える等 |
| アラーム音のカスタマイズ | 低 | 現在は固定の1音源 |
| 10分自動停止後の挙動 | 中 | 現在はホーム画面に戻るだけ。失敗画面・リトライ等を検討 |
| バックグラウンド閉じ対策 | 高 | アプリを閉じた場合のローカル通知フォールバック |
| 達成履歴・統計画面 | 低 | 何日連続で起きたか等 |
| Android対応 | 中 | カメラのImageFormat等の対応が必要 |
| AudioSession設定 | 高 | ミュートスイッチON時でもアラームを鳴らすための `.playback` カテゴリ設定（現在未実装） |
| 暗所検知・警告 | 低 | カメラの明るさチェックによる案内表示 |

---

## 8. 開発環境セットアップ

```bash
# 1. 依存パッケージ取得
flutter pub get

# 2. 静的解析
flutter analyze

# 3. デバッグ実行（実機）
flutter run -d <device-id>

# 4. リリースビルド（実機、ケーブル不要で動作）
flutter run --release -d <device-id>

# 接続中のデバイスID確認
flutter devices
```

### 注意事項

- カメラとポーズ検出は**シミュレータでは動作しない**。実機が必要
- フロントカメラ使用のため、全身が映る距離にスマホを設置する必要がある
- 明るい部屋での使用を前提としている（暗所ではポーズ検出精度が下がる）
