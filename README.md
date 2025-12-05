✨ Flutter CustomPainter & Physics Simulation Learning Project
このリポジトリは、Flutterの基本的なウィジェット操作から一歩進み、カスタム描画（CustomPainter）と物理シミュレーションの基礎を段階的に習得するために作成された学習プロジェクトです。

## 🎯 プロジェクトの目標
FlutterのAnimationControllerとTickerを使った連続的なアニメーションループの実現。

画面上に自由に図形を描画するCustomPainterの習得。

三角関数や物理法則（自由落下、単振り子の運動方程式）に基づいた座標計算の実装。

数値積分（オイラー法）を用いた**複雑なシミュレーション（二重振り子）**への挑戦。

## 🚀 成果物（アプリ一覧）
以下の4つのアプリを、段階的に作成・完成させました。

1. タップで描画され、消える円アプリ (Dissolving Circle)
- 機能
  - 画面をタップすると、その位置から円が拡大しながら透明になって消える。
- 学んだこと
  - GestureDetectorによるタップ座標の取得。AnimationControllerによる1回限りのアニメーション制御。CustomPainterを使った透明度と半径の動的な変化。

2. シンプルな円運動アプリ (Circular Motion)
- 機能
  - 画面の中心を軸に、ボールが一定の半径で回り続ける
- 学んだこと
  - AnimationController.repeat()による永続的なループアニメーション。sin()とcos()を使用した極座標から直交座標への変換と座標計算。

3. 自由落下アプリ (Free Fall)
- 機能
  - 画面上部からボールを落とし、画面外に出るとリセットされ再落下する。
- 学んだこと
  - DateTimeを使用した正確な経過時間 ($\Delta t$) の計算。高校物理の公式 $y = \frac{1}{2}gt^2$ を使った時間依存の座標計算。

4. 単振り子アプリ (Simple Pendulum)
- 機能
  - 糸に吊るされたボールが、摩擦（減衰）によって徐々に静止するまで揺れ続ける。
- 学んだこと
  - $\sin\theta$ を用いた復元力の計算。オイラー法（Euler Integration）による角度と角速度の数値積分。**減衰（Damping）**の適用。

5. 二重振り子アプリ (Double Pendulum)
- 機能
  - 2つの振り子が連動し、**カオス（Chaos）**的な複雑で予測不能な動きをシミュレーションする。
- 学んだこと
  - 4つの状態変数（$\theta_1, \omega_1, \theta_2, \omega_2$）の同時追跡と更新。複雑な運動方程式の適用。**軌跡（Trajectory）**の描画。


## ⚙️ 実行方法
1.本リポジトリをクローンします。
'''bash
git clone [リポジトリのURL]
'''

2.プロジェクトディレクトリに移動します。
'''bash
cd [プロジェクト名]
'''

3.必要なパッケージをインストールします。
'''bash
flutter pub get
'''

4.macOSシミュレーターまたは実機で起動します。
'''bash
flutter run
'''


※各アプリを実行するには、lib/main.dart の home: に対応するクラス（例: FreeFallScreen(), DoublePendulumScreen() など）を指定してビルドし直してください。