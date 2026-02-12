import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Student: Nitesh Kumar
// Team Member: Kourikanti Koushik
// Assignment: In-Class Activity 03 - Cupid's Code Challenge

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  
  // logic for the Balloon Celebration
  bool _isCelebrating = false;
  List<Widget> _balloons = [];

  // logic for the Pulse Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    setState(() {
      _isCelebrating = true;
      // generating 20 random balloons
      _balloons = List.generate(20, (index) => const Balloon());
    });

    // stop celebrating after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isCelebrating = false;
          _balloons = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // select image based on the dropdown choice
    String backgroundImage = selectedEmoji == 'Sweet Heart' 
        ? 'assets/images/love-theme.jpg' 
        : 'assets/images/heart_confetti.jpg';

    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Stack(
        children: [
          // lAYER 1 background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), 
                  BlendMode.lighten
                ),
              ),
            ),
          ),

          // lAYER 2 main Content
          Column(
            children: [
              const SizedBox(height: 16),
              
              // emoji Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedEmoji,
                    items: emojiOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
                  ),
                ),
              ),

              const Spacer(),

              // the custom painter heart (Animated)
              ScaleTransition(
                scale: _pulseAnimation,
                child: Center(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: HeartEmojiPainter(type: selectedEmoji),
                  ),
                ),
              ),

              const Spacer(),

              // celebrate Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton.icon(
                  onPressed: _triggerCelebration,
                  icon: const Icon(Icons.celebration, color: Colors.white),
                  label: const Text("Celebrate Love!"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // LAYER 3: Animated Balloons Overlay
          if (_isCelebrating) 
            ..._balloons,
        ],
      ),
    );
  }
}


class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // 1 - draw main heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    // Gradient or Color Fill
    final gradient = LinearGradient(
      colors: type == 'Party Heart' 
          ? [const Color(0xFFF48FB1), const Color(0xFFAD1457)] 
          : [const Color(0xFFEF5350), const Color(0xFFB71C1C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(heartPath, paint);

    // drawing faces based on selection
    if (type == 'Party Heart') {
      _drawPartyFace(canvas, center);
    } else {
      _drawLovestruckFace(canvas, center);
    }
  }

  // 
  void _drawLovestruckFace(Canvas canvas, Offset center) {
    // replaced circles with heart shape for eyes
    // left Eye Heart
    _drawMiniHeart(canvas, Offset(center.dx - 35, center.dy - 20), 12, Colors.white);
    // right Eye Heart
    _drawMiniHeart(canvas, Offset(center.dx + 35, center.dy - 20), 12, Colors.white);

    // big joyful smile
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 25), 0.2, 2.7, false, mouthPaint);
  }

  // --- party face (wink + hat) ---
  void _drawPartyFace(Canvas canvas, Offset center) {
    // party hat
    final hatPaint = Paint()..color = const Color(0xFFFFD54F);
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 110) // top tip
      ..lineTo(center.dx - 30, center.dy - 50) // bottom left
      ..lineTo(center.dx + 30, center.dy - 50) // bottom right
      ..close();
    canvas.drawPath(hatPath, hatPaint);
    
    // winking face
    final strokePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4;
    // wink left
    canvas.drawLine(Offset(center.dx - 40, center.dy - 10), Offset(center.dx - 20, center.dy - 10), strokePaint);
    // open right
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 8, Paint()..color = Colors.white);
    // mouth
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 20), 0, 3.14, false, strokePaint);
    
    // confetti dots
    final random = Random(123); // fixed seed for stable drawing
    for(int i=0; i<15; i++) {
        final confettiPaint = Paint()..color = Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        canvas.drawCircle(Offset(center.dx + (random.nextInt(100)-50), center.dy + (random.nextInt(100)-50)), 3, confettiPaint);
    }
  }

  // helper to draw mini hearts (for the eyes)
  void _drawMiniHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    // simplified heart shape logic relative to the mini-center
    path.moveTo(center.dx, center.dy + size);
    path.cubicTo(center.dx + size * 1.5, center.dy, center.dx + size, center.dy - size, center.dx, center.dy - size/2);
    path.cubicTo(center.dx - size, center.dy - size, center.dx - size * 1.5, center.dy, center.dx, center.dy + size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}

// animated baloon
class Balloon extends StatefulWidget {
  const Balloon({super.key});

  @override
  State<Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2 + _random.nextInt(3)), 
      vsync: this,
    )..forward();

    final startX = -1.0 + _random.nextDouble() * 2.0; 
    final endX = startX + (_random.nextDouble() * 0.5 - 0.25); 

    _animation = AlignmentTween(
      begin: Alignment(startX, 1.5), 
      end: Alignment(endX, -1.5),    
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlignTransition(
      alignment: _animation,
      child: Icon(
        Icons.favorite,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        size: 30.0 + _random.nextInt(30),
      ),
    );
  }
}