import 'package:flutter/material.dart';
import 'dart:math'; // sin, cos, pi を使うために必要

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CircularMotionScreen(),
    );
  }
}

class CircularMotionScreen extends StatefulWidget {
  const CircularMotionScreen({super.key});

  @override
  State<CircularMotionScreen> createState() => _CircularMotionScreenState();
}

// TickerProviderStateMixin を使用してアニメーションループを作成
class _CircularMotionScreenState extends State<CircularMotionScreen>
    with SingleTickerProviderStateMixin {

  // 1. アニメーションコントローラー
  late AnimationController _controller;
  // 2. 半径
  final double radius = 150.0;
  // 3. ボールのサイズ
  final double ballSize = 20.0;

  @override
  void initState() {
    super.initState();
    // 4. コントローラーを初期化
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4秒で一周とする
    );

    // 5. アニメーションを繰り返す設定
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('円運動アプリ')),
      body: Center(
        child: Container(
          color: Colors.black, // 背景を黒にしてボールを見やすくする
          width: double.infinity,
          height: double.infinity,

          // 6. AnimatedBuilder: コントローラーの値が変わるたびに再描画する
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // アニメーションの値 (0.0 から 1.0) を取得
              final double animationValue = _controller.value;

              // 7. 現在の角度を計算 (0から2πラジアン)
              // 2 * pi (約6.28) で一周分
              final double angle = 2 * pi * animationValue;

              // 8. 座標を三角関数で計算
              // x = 中心x + 半径 * cos(角度)
              // y = 中心y + 半径 * sin(角度)
              final double currentX = radius * cos(angle);
              final double currentY = radius * sin(angle);

              // 9. CustomPaintで描画する
              return CustomPaint(
                painter: CircularPainter(
                  currentPosition: Offset(currentX, currentY),
                  radius: radius,
                  ballSize: ballSize,
                ),
                // CustomPaint自体を画面の中心に配置するために使用
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// CustomPainter クラス (描画を担当)
// ----------------------------------------------------------------------

class CircularPainter extends CustomPainter {
  final Offset currentPosition;
  final double radius;
  final double ballSize;

  CircularPainter({required this.currentPosition, required this.radius, required this.ballSize});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 描画の中心を計算（画面の中央）
    final center = Offset(size.width / 2, size.height / 2);

    // 2. 軌跡（円）を描画
    final pathPaint = Paint()
      ..color = Color.fromRGBO(
          30,      // R (赤)
          70,      // G (緑)
          90,      // B (青)
          1.0 - radius // A (アルファ値 = 透明度) 1.0から0.0へ
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, pathPaint);

    // 3. ボールの描画位置を計算（centerからの相対位置 + centerの絶対位置）
    final ballCenter = center + currentPosition;

    // 4. ボール本体を描画
    final ballPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ballCenter, ballSize / 2, ballPaint);
  }

  @override
  bool shouldRepaint(covariant CircularPainter oldDelegate) {
    // 座標が変わるたびに再描画を指示
    return oldDelegate.currentPosition != currentPosition;
  }
}