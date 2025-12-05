import 'package:flutter/material.dart';
import 'package:flush_circle_app/freefall.dart'; // 自由落下のコード呼び出し
import 'package:flush_circle_app/pendulum.dart'; //　振り子v1(円運動)
import 'package:flush_circle_app/SimplePendulum.dart'; // 振り子v2(単純振り子)

// 単純振り子
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

// 円運動

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       // ★ ここで freefall.dart や　pendulum.dart で定義したクラスを呼び出します
//       home: CircularMotionScreen(),
//     );
//   }
// }

// 自由落下

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       // ★ ここで freefall.dart で定義したクラスを呼び出します
//       home: FreeFallScreen(),
//     );
//   }
// }


// 消える円アプリ
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: CircleTapScreen(),
//     );
//   }
// }
//
// class CircleTapScreen extends StatefulWidget {
//   const CircleTapScreen({super.key});
//
//   @override
//   State<CircleTapScreen> createState() => _CircleTapScreenState();
// }
//
// class _CircleTapScreenState extends State<CircleTapScreen>
//     with SingleTickerProviderStateMixin { // 👈 AnimationControllerを使うためのmixin
//
//   // 1. タップされた円の情報 (座標とアニメーションコントローラ)
//   Offset? _tapPosition;
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     // 2. AnimationControllerの初期化 (アニメーション時間: 1秒)
//     _controller = AnimationController(
//       vsync: this, // TickerProviderを指定
//       duration: const Duration(seconds: 1),
//     );
//     // 3. アニメーションの値 (0.0 から 1.0)
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
//
//     // アニメーションが終わったら、円の情報をクリア
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           _tapPosition = null; // 座標をリセット
//         });
//         _controller.reset(); // コントローラをリセット
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   // 4. タップされたときの処理
//   void _handleTap(TapDownDetails details) {
//     // 既にアニメーションが進行中の場合は何もしない
//     if (_controller.isAnimating) {
//       return;
//     }
//
//     setState(() {
//       _tapPosition = details.localPosition; // 画面内での相対座標を取得
//     });
//
//     _controller.forward(); // アニメーションを開始 (0.0 -> 1.0へ)
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('消える円アプリ')),
//       // 5. GestureDetectorで画面全体のタップを検出
//       body: SizedBox.expand( // 👈 ★追加: 画面全体に広げる
//         child: GestureDetector(
//         onTapDown: _handleTap,
//         child: Container(
//           color: Colors.lightBlue, // 背景を黒にして、描画される白い円を見やすくする
//           width: double.infinity,
//           height: double.infinity,
//           // 6. CustomPaintで描画ロジックを呼び出す
//           child: AnimatedBuilder(
//             animation: _animation, // _animationの値が変化するたびにbuilderが実行される
//             builder: (context, child) {
//               if (_tapPosition == null) {
//                 return const SizedBox.expand(); // タップがない場合は何も描画しない
//               }
//               return CustomPaint(
//                 painter: CirclePainter(
//                   tapPosition: _tapPosition!,
//                   animationValue: _animation.value, // アニメーションの現在の値 (0.0〜1.0)
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       ),
//     );
//   }
// }
//
// // ----------------------------------------------------------------------
// // CustomPainter クラス (描画を担当)
// // ----------------------------------------------------------------------
//
// class CirclePainter extends CustomPainter {
//   final Offset tapPosition;
//   final double animationValue;
//
//   CirclePainter({required this.tapPosition, required this.animationValue});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // 1. 塗りの設定
//     final paint = Paint()
//     // ★★★ 修正: Color.fromRGBO を使って、透明度(A)を直接指定する ★★★
//       ..color = Color.fromRGBO(
//           30,      // R (赤)
//           70,      // G (緑)
//           90,      // B (青)
//           1.0 - animationValue // A (アルファ値 = 透明度) 1.0から0.0へ
//       )
//       ..style = PaintingStyle.fill; // この行は維持
//
//     // 2. 円の半径を計算
//     final maxRadius = 100.0;
//     final radius = maxRadius * animationValue;
//
//     // 3. 円を描画
//     canvas.drawCircle(tapPosition, radius, paint);
//   }
//
//
//   @override
//   bool shouldRepaint(covariant CirclePainter oldDelegate) {
//     // アニメーション値が変わるたびに再描画を指示
//     return oldDelegate.animationValue != animationValue;
//   }
// }