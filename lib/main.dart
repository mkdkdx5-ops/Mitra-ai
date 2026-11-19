
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MitraAI());
}

class MitraAI extends StatelessWidget {
  const MitraAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mitra AI - Jarvis',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D9FF),
          secondary: Color(0xFF168CFF),
        ),
      ),
      home: const JarvisHome(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class JarvisHome extends StatefulWidget {
  const JarvisHome({super.key});

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome>
    with TickerProviderStateMixin {

  late AnimationController breathe;
  late AnimationController rotate;
  late stt.SpeechToText speech;
  late FlutterTts tts;

  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  final List<ChatMessage> messages = [];

  bool listening = false;
  bool speaking = false;
  bool ready = false;
  bool english = false;

  String status = 'JARVIS ONLINE';
  String recognizedText = '';

  @override
  void initState() {
    super.initState();

    breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    rotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    speech = stt.SpeechToText();
    tts = FlutterTts();

    initializeJarvis();
  }

  Future<void> initializeJarvis() async {
    try {
      ready = await speech.initialize(
        onStatus: (value) {
          if (value == 'notListening' && mounted) {
            setState(() => listening = false);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              listening = false;
              status = 'MICROPHONE ERROR';
            });
          }
        },
      );

      await tts.setSpeechRate(0.45);
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);

      if (mounted) {
        setState(() => status = 'JARVIS ONLINE');
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> speak(String text) async {
    await tts.stop();

    if (!mounted) return;

    setState(() {
      speaking = true;
      status = 'JARVIS SPEAKING';
    });

    await tts.setLanguage(english ? 'en-IN' : 'hi-IN');
    await tts.speak(text);

    if (mounted) {
      setState(() {
        speaking = false;
        status = 'JARVIS ONLINE';
      });
    }
  }

  Future<void> startListening() async {
    if (!ready) {
      await initializeJarvis();
    }

    if (!ready) {
      showMessage('Microphone service उपलब्ध नहीं है।');
      return;
    }

    await tts.stop();

    setState(() {
      listening = true;
      speaking = false;
      recognizedText = '';
      status = 'LISTENING...';
    });

    await speech.listen(
      localeId: english ? 'en_IN' : 'hi_IN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          recognizedText = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() => listening = false);

          if (recognizedText.trim().isNotEmpty) {
            sendMessage(recognizedText);
          } else {
            setState(() => status = 'JARVIS ONLINE');
          }
        }
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    if (mounted) {
      setState(() {
        listening = false;
        status = 'JARVIS ONLINE';
      });
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void addMessage(String text, bool user) {
    setState(() {
      messages.add(ChatMessage(text, user));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage([String? voiceText]) async {
    final text = (voiceText ?? input.text).trim();

    if (text.isEmpty) return;

    input.clear();
    addMessage(text, true);

    setState(() => status = 'THINKING...');

    final answer = getLocalAnswer(text);

    addMessage(answer, false);

    await speak(answer);
  }

  String getLocalAnswer(String text) {
    final q = text.toLowerCase();

    if (q.contains('hello') ||
        q.contains('नमस्ते') ||
        q.contains('हेलो')) {
      return english
          ? 'Hello! I am Jarvis. How can I help you?'
          : 'नमस्ते! मैं Jarvis हूँ। बताइए, मैं आपकी क्या मदद करूँ?';
    }

    if (q.contains('your name') ||
        q.contains('नाम') ||
        q.contains('कौन हो')) {
      return english
          ? 'My name is Jarvis, your Mitra AI assistant.'
          : 'मेरा नाम Jarvis है। मैं आपका Mitra AI Assistant हूँ।';
    }

    if (q.contains('time') || q.contains('समय')) {
      final now = TimeOfDay.now();
      return english
          ? 'The time is ${now.format(context)}.'
          : 'अभी समय ${now.format(context)} है।';
    }

    if (q.contains('date') || q.contains('तारीख')) {
      final now = DateTime.now();
      return english
          ? 'Today is ${now.day}-${now.month}-${now.year}.'
          : 'आज ${now.day}-${now.month}-${now.year} है।';
    }

    if (q.contains('your creator') ||
        q.contains('किसने बनाया')) {
      return english
          ? 'I am being developed as your Mitra AI project.'
          : 'मुझे Mitra AI प्रोजेक्ट के रूप में बनाया जा रहा है।';
    }

    if (q.contains('stop') ||
        q.contains('बंद करो')) {
      return english
          ? 'Okay. I am ready when you need me.'
          : 'ठीक है। जब जरूरत हो, मुझे बुलाइए।';
    }

    if (q.contains('help') || q.contains('मदद')) {
      return english
          ? 'I can tell you the time, date and respond to basic commands. Internet AI will be connected separately.'
          : 'मैं अभी समय, तारीख और कुछ बेसिक कमांड समझ सकता हूँ। इंटरनेट AI अलग से कनेक्ट किया जाएगा।';
    }

    return english
        ? 'I heard you say: $text. My online AI connection is not configured yet.'
        : 'मैंने सुना: $text। मेरा ऑनलाइन AI कनेक्शन अभी सेटअप नहीं हुआ है।';
  }

  @override
  void dispose() {
    breathe.dispose();
    rotate.dispose();
    input.dispose();
    scroll.dispose();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            header(),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 5,
                    child: orbSection(),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      letterSpacing: 4,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: chatSection(),
                  ),
                ],
              ),
            ),
            inputSection(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: Color(0xFF00D9FF),
            size: 27,
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MITRA AI',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'POWERED BY JARVIS',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() => english = !english);
              showMessage(
                english ? 'English mode' : 'Hindi mode',
              );
            },
            icon: const Icon(
              Icons.language,
              color: Color(0xFF00D9FF),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => messages.clear());
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget orbSection() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([breathe, rotate]),
        builder: (context, child) {
          final scale = 0.94 + breathe.value * 0.10;

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 255,
              height: 255,
              child: CustomPaint(
                painter: OrbPainter(
                  rotation: rotate.value * math.pi * 2,
                  glow: breathe.value,
                  active: listening || speaking,
                ),
                child: const Center(
                  child: Icon(
                    Icons.all_inclusive,
                    color: Colors.white,
                    size: 75,
                    shadows: [
                      Shadow(
                        color: Color(0xFF00D9FF),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget chatSection() {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.graphic_eq,
              size: 32,
              color: Color(0xFF00D9FF),
            ),
            SizedBox(height: 8),
            Text(
              'Hello, I am Jarvis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tap the microphone to talk',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];

        return Align(
          alignment: msg.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? const Color(0xFF075985)
                  : const Color(0xFF101B2B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF00D9FF).withOpacity(0.25),
              ),
            ),
            child: Text(
              msg.text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget inputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 15),
      decoration: const BoxDecoration(
        color: Color(0xFF091321),
        border: Border(
          top: BorderSide(color: Color(0xFF153047)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: input,
              onSubmitted: (_) => sendMessage(),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ask Jarvis anything...',
                hintStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF142338),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: listening
                ? stopListening
                : startListening,
            style: IconButton.styleFrom(
              backgroundColor: listening
                  ? Colors.red
                  : const Color(0xFF007FA8),
              foregroundColor: Colors.white,
              fixedSize: const Size(48, 48),
            ),
            icon: Icon(
              listening ? Icons.stop : Icons.mic,
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () => sendMessage(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF00A8CC),
              foregroundColor: Colors.white,
              fixedSize: const Size(48, 48),
            ),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class OrbPainter extends CustomPainter {
  final double rotation;
  final double glow;
  final bool active;

  OrbPainter({
    required this.rotation,
    required this.glow,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    final color = active
        ? const Color(0xFF55EEFF)
        : const Color(0xFF008CFF);

    final outerGlow = Paint()
      ..color = color.withOpacity(0.16 + glow * 0.12)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        35,
      );

    canvas.drawCircle(center, radius + 22, outerGlow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00FFFF),
          Color(0xFF0066FF),
          Color(0xFF8B5CFF),
          Color(0xFF00FFFF),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius + 15),
      );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawCircle(center, radius + 15, ringPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 24),
      0,
      math.pi * 1.35,
      false,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();

    final ballPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 0.95,
        colors: [
          Color(0xFFB9FFFF),
          Color(0xFF19B9FF),
          Color(0xFF0644B5),
          Color(0xFF020A29),
        ],
        stops: [0.0, 0.25, 0.65, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, ballPaint);

    final shine = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawCircle(
      center + Offset(-radius * 0.3, -radius * 0.35),
      radius * 0.13,
      shine,
    );

    final orbitPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2.5,
        height: radius * 0.65,
      ),
      orbitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.glow != glow ||
        oldDelegate.active != active;
  }
}
