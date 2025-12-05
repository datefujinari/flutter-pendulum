import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DoublePendulumScreen(),
    );
  }
}

class DoublePendulumScreen extends StatefulWidget {
  const DoublePendulumScreen({super.key});

  @override
  State<DoublePendulumScreen> createState() => _DoublePendulumScreenState();
}

class _DoublePendulumScreenState extends State<DoublePendulumScreen>
    with SingleTickerProviderStateMixin {

  // 1. 物理定数 (調整して動きを変えてみてください)
  final double G = 9.8 * 150;    // 重力加速度
  final double L1 = 150.0;       // 1番目の振り子の長さ
  final double L2 = 200.0;       // 2番目の振り子の長さ
  final double M1 = 12.0;        // 1番目の振り子の質量
  final double M2 = 18.0;        // 2番目の振り子の質量
  final double DAMPING = 0.9999; // 減衰率

  // 2. 物理変数 (状態)
  double _angle1 = pi / 2;      // 1番目の初期角度 (90度)
  double _angularVelocity1 = 0.0;
  double _angle2 = pi / 2;      // 2番目の初期角度 (90度)
  double _angularVelocity2 = 0.0;

  // 3. 軌跡の履歴
  final List<Offset> _trajectory = [];
  final int maxTrajectoryPoints = 500;

  // 4. 時間追跡
  late AnimationController _controller;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );

    _controller.addListener(_updatePhysics);
    _controller.forward();
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

    // 時間差分 (Δt) を秒単位で取得
    final double deltaTime = DateTime.now().difference(_lastUpdateTime!).inMicroseconds / 1000000.0;
    _lastUpdateTime = DateTime.now();

    // 複雑な二重振り子の運動方程式の計算 (分子と分母を計算)

    final double sinDelta = sin(_angle1 - _angle2);
    final double cosDelta = cos(_angle1 - _angle2);
    final double cos2Delta = cos(2 * (_angle1 - _angle2));

    // θ1の角加速度 (α1) の分子
    final double num1 = -G * (2 * M1 + M2) * sin(_angle1)
        - M2 * G * sin(_angle1 - 2 * _angle2)
        - 2 * M2 * sinDelta * (_angularVelocity2 * _angularVelocity2 * L2 + _angularVelocity1 * _angularVelocity1 * L1 * cosDelta);

    // θ1の角加速度 (α1) の分母
    final double den = L1 * (2 * M1 + M2 - M2 * cos2Delta);
    final double angularAcceleration1 = num1 / den;

    // θ2の角加速度 (α2) の分子
    final double num2 = 2 * sinDelta * (_angularVelocity1 * _angularVelocity1 * L1 * (M1 + M2)
        + G * (M1 + M2) * cos(_angle1)
        + _angularVelocity2 * _angularVelocity2 * L2 * M2 * cosDelta);

    // θ2の角加速度 (α2) の分母
    final double den2 = L2 * (2 * M1 + M2 - M2 * cos2Delta);
    final double angularAcceleration2 = num2 / den2;

    // オイラー法による状態更新
    _angularVelocity1 += angularAcceleration1 * deltaTime;
    _angularVelocity2 += angularAcceleration2 * deltaTime;

    // 減衰を適用
    _angularVelocity1 *= DAMPING;
    _angularVelocity2 *= DAMPING;

    _angle1 += _angularVelocity1 * deltaTime;
    _angle2 += _angularVelocity2 * deltaTime;

    // 描画のために状態を更新し、軌跡を記録
    setState(() {
      // 2番目の振り子の座標を計算し、軌跡に追加
      final double x2 = L1 * sin(_angle1) + L2 * sin(_angle2);
      final double y2 = L1 * cos(_angle1) + L2 * cos(_angle2);
      _trajectory.add(Offset(x2, y2));

      // 軌跡が最大数を超えたら、最も古いものを削除
      if (_trajectory.length > maxTrajectoryPoints) {
        _trajectory.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二重振り子アプリ (カオス)')),

      body: Container(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // 振り子の中心座標
            final Offset pivot = Offset(screenWidth / 2, screenHeight / 4);

            // 1番目のボールの位置 (X1, Y1)
            final double x1 = L1 * sin(_angle1);
            final double y1 = L1 * cos(_angle1);
            final Offset ballPosition1 = pivot + Offset(x1, y1);

            // 2番目のボールの位置 (X2, Y2)
            final double x2 = x1 + L2 * sin(_angle2);
            final double y2 = y1 + L2 * cos(_angle2);
            final Offset ballPosition2 = pivot + Offset(x2, y2);

            return CustomPaint(
              painter: DoublePendulumPainter(
                pivot: pivot,
                ballPosition1: ballPosition1,
                ballPosition2: ballPosition2,
                trajectory: _trajectory,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// CustomPainter クラス (描画を担当)
// ----------------------------------------------------------------------

class DoublePendulumPainter extends CustomPainter {
  final Offset pivot;
  final Offset ballPosition1;
  final Offset ballPosition2;
  final List<Offset> trajectory;

  DoublePendulumPainter({
    required this.pivot,
    required this.ballPosition1,
    required this.ballPosition2,
    required this.trajectory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 軌跡の描画 (2番目のボールの動きを追跡)
    final trailPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 軌跡を描画するため、座標をPivotからの相対座標から絶対座標に変換
    final Offset center = pivot - trajectory.first; // 変換基準のオフセット

    final path = Path();
    if (trajectory.isNotEmpty) {
      path.moveTo(pivot.dx + trajectory.first.dx, pivot.dy + trajectory.first.dy);
      for (final pos in trajectory) {
        // Pivotからの相対座標を画面の絶対座標に変換
        path.lineTo(pivot.dx + pos.dx, pivot.dy + pos.dy);
      }
      canvas.drawPath(path, trailPaint);
    }

    // 糸のPaint設定
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // 1. 1番目の糸 (Pivot から Ball 1)
    canvas.drawLine(pivot, ballPosition1, linePaint);

    // 2. 2番目の糸 (Ball 1 から Ball 2)
    canvas.drawLine(ballPosition1, ballPosition2, linePaint);

    // 3. ボールの描画
    const double ballSize = 30.0;
    final ballPaint1 = Paint()..color = Colors.blue;
    final ballPaint2 = Paint()..color = Colors.red;

    canvas.drawCircle(ballPosition1, ballSize / 2, ballPaint1);
    canvas.drawCircle(ballPosition2, ballSize / 2, ballPaint2);

    // 4. 支点の描画
    final pivotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(pivot, 5.0, pivotPaint);
  }

  @override
  bool shouldRepaint(covariant DoublePendulumPainter oldDelegate) {
    // ボールの座標と軌跡が変わるたびに再描画を指示
    return oldDelegate.ballPosition2 != ballPosition2 || oldDelegate.trajectory.length != trajectory.length;
  }
}