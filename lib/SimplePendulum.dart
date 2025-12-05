import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui'; // PaintingStyleのためにインポート

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SimplePendulumScreen(),
    );
  }
}

class SimplePendulumScreen extends StatefulWidget {
  const SimplePendulumScreen({super.key});

  @override
  State<SimplePendulumScreen> createState() => _SimplePendulumScreenState();
}

class _SimplePendulumScreenState extends State<SimplePendulumScreen>
    with SingleTickerProviderStateMixin {

  // 1. 物理定数
  final double G = 9.8 * 100; // 重力加速度 (画面スケールで調整)
  final double LENGTH = 250.0; // 振り子の長さ (L)
  final double DAMPING = 0.999; // 減衰率 (抵抗)

  // 2. 物理変数 (状態)
  double _angle = pi / 4; // 初期角度 (45度 = π/4 ラジアン)
  double _angularVelocity = 0.0; // 角速度 (ω)

  // 3. アニメーションと時間の追跡
  late AnimationController _controller;
  // 前回のフレームが更新された時刻 (物理計算のΔtを求めるために必要)
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // 長い時間を設定し、手動でティックを管理
    );

    // 4. アニメーションティック (フレーム更新) ごとに物理法則を適用
    _controller.addListener(_updatePhysics);

    _controller.forward(); // アニメーションを開始
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------
  // 5. 物理更新ループ (オイラー法による数値積分)
  // ----------------------------------------------------------------------
  void _updatePhysics() {
    if (_lastUpdateTime == null) {
      _lastUpdateTime = DateTime.now();
      return;
    }

    // 現在時刻と前回の時刻の差分から、経過時間 (Δt) を秒単位で取得
    final double deltaTime = DateTime.now().difference(_lastUpdateTime!).inMicroseconds / 1000000.0;
    _lastUpdateTime = DateTime.now();

    // 振り子の角加速度 (α) を計算
    // α = - (G / L) * sin(θ)
    final double angularAcceleration = -(G / LENGTH) * sin(_angle);

    // オイラー法による角速度の更新 (ω = ω + α * Δt)
    _angularVelocity += angularAcceleration * deltaTime;

    // 減衰（空気抵抗など）を適用
    _angularVelocity *= DAMPING;

    // オイラー法による角度の更新 (θ = θ + ω * Δt)
    _angle += _angularVelocity * deltaTime;

    // 描画のために状態を更新
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('単振り子アプリ')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // 振り子の中心座標 (画面中央の上部から少し下げた位置)
          final Offset pivot = Offset(screenWidth / 2, 50);

          // 6. 角度からボールの描画座標を計算 (極座標から直交座標への変換)
          // X = L * sin(θ)
          // Y = L * cos(θ)
          final double x = LENGTH * sin(_angle);
          final double y = LENGTH * cos(_angle);

          // 描画位置は、中心(pivot)からの相対位置(x, y)を足したもの
          final Offset ballPosition = pivot + Offset(x, y);

          return CustomPaint(
            painter: PendulumPainter(
              pivot: pivot,
              ballPosition: ballPosition,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------
// CustomPainter クラス (描画を担当)
// ----------------------------------------------------------------------

class PendulumPainter extends CustomPainter {
  final Offset pivot;
  final Offset ballPosition;

  PendulumPainter({required this.pivot, required this.ballPosition});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 糸のPaint設定
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;

    // 2. 糸を描画 (中心からボールへ)
    canvas.drawLine(pivot, ballPosition, linePaint);

    // 3. ボールのPaint設定
    final ballPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    const double ballSize = 25.0;

    // 4. ボールを描画
    canvas.drawCircle(ballPosition, ballSize / 2, ballPaint);

    // 5. 支点を描画
    final pivotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(pivot, 5.0, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant PendulumPainter oldDelegate) {
    // ボールの座標が変わるたびに再描画を指示
    return oldDelegate.ballPosition != ballPosition;
  }
}