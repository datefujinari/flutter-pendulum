import 'package:flutter/material.dart';
import 'dart:ui';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FreeFallScreen(),
    );
  }
}

class FreeFallScreen extends StatefulWidget {
  const FreeFallScreen({super.key});

  @override
  State<FreeFallScreen> createState() => _FreeFallScreenState();
}

class _FreeFallScreenState extends State<FreeFallScreen>
    with SingleTickerProviderStateMixin {

  // 1. 物理定数
  // G (重力加速度) m/s^2 に相当する値。ここでは画面上の動きやすさで調整
  final double gravity = 9.8 * 100; // 画面上のスケールで調整

  // 2. アニメーションコントローラー
  late AnimationController _controller;

  // 3. 経過時間 (duration) を保持するための変数
  // Tickerが開始されてから経過した時間 (Duration) を保持
  Duration _elapsedTime = Duration.zero;

  // 4. アニメーションが開始された絶対時刻を保持
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    // 5. コントローラーを初期化
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // 実際には非常に長く設定し、手動で停止させる
    );

    // 6. コントローラーのティック（フレーム更新）ごとに実行されるリスナーを設定
    _controller.addListener(() {
      // 現在時刻から開始時刻を引いて、経過時間を正確に計算
      final Duration currentDuration = DateTime.now().difference(_startTime);

      // 画面が更新されるたびにsetStateを呼び出し、再描画を要求
      setState(() {
        _elapsedTime = currentDuration;
      });
    });

    // 7. アニメーションを開始
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自由落下アプリ')),
      body: LayoutBuilder( // 画面のサイズを取得するためにLayoutBuilderを使用
        builder: (context, constraints) {
          // 画面の高さ (H) と幅 (W) を取得
          final double screenHeight = constraints.maxHeight;
          final double screenWidth = constraints.maxWidth;

          // 8. 経過時間を秒単位 (t) に変換
          final double t = _elapsedTime.inMilliseconds / 1000.0;

          // 9. 自由落下の計算
          // y = 1/2 * g * t^2
          final double yPosition = 0.5 * gravity * (t * t);

          // 10. ボールが画面外に出たらリセット
          if (yPosition > screenHeight + 50) {
            // リセット処理
            _startTime = DateTime.now(); // スタート時刻をリセット
            _elapsedTime = Duration.zero;
          }

          // 11. CustomPaintで描画ロジックを呼び出す
          return CustomPaint(
            painter: FreeFallPainter(
              yPosition: yPosition,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
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

class FreeFallPainter extends CustomPainter {
  final double yPosition;
  final double screenWidth;
  final double screenHeight;

  FreeFallPainter({required this.yPosition, required this.screenWidth, required this.screenHeight});

  @override
  void paint(Canvas canvas, Size size) {
    const double ballSize = 30.0;

    // ボールのPaint設定
    final ballPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // ボールの描画座標 (Xは画面中央、Yは計算された落下位置)
    // 画面のY座標は上（0）から下（最大値）に向かって増加します。
    final ballCenter = Offset(screenWidth / 2, yPosition);

    // ボールを描画
    canvas.drawCircle(ballCenter, ballSize / 2, ballPaint);
  }

  @override
  bool shouldRepaint(covariant FreeFallPainter oldDelegate) {
    // Y座標が変わるたびに再描画を指示
    return oldDelegate.yPosition != yPosition;
  }
}