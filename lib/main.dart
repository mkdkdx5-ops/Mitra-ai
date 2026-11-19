
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MitraAI());
}

class MitraAI extends StatelessWidget {
  const MitraAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mitra AI',
      theme: ThemeData.dark(),
      home: const MitraHome(),
    );
  }
}

class MitraHome extends StatefulWidget {
  const MitraHome({super.key});

  @override
  State<MitraHome> createState() => _MitraHomeState();
}

class _MitraHomeState extends State<MitraHome>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  final TextEditingController input = TextEditingController();

  bool listening = false;
  bool hindi = true;

  String status = 'Your AI Assistant';
  String response = 'Hello! I am Mitra. How can I help you?';

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    input.dispose();
    super.dispose();
  }

  void toggleVoice() {
    setState(() {
      listening = !listening;
      status = listening ? 'Listening Demo...' : 'Your AI Assistant';
      response = listening
          ? 'Voice demo started. Real microphone support will be added next.'
          : 'Voice demo stopped. Type a message below.';
    });
  }

  void sendMessage() {
    if (input.text.trim().isEmpty) return;

    String message = input.text.trim();

    setState(() {
      response = 'You: $message\n\nMitra: Hello! I received your message. Smart AI connection will be added in the next version.';
      status = 'Ready to help';
      listening = false;
      input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: SafeArea(
        child: Column(
          children: [

            // TOP BAR
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.cyanAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MITRA AI',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        hindi = !hindi;
                        response = hindi
                            ? 'Hindi mode selected.'
                            : 'English mode selected.';
                      });
                    },
                    icon: const Icon(
                      Icons.language,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  Text(hindi ? 'HI' : 'EN'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'YOUR PERSONAL ASSISTANT',
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 3,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 35),

            // ANIMATED AI BALL
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                double scale =
                    1.0 + controller.value * 0.09;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 225,
                    height: 225,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.9),
                          Colors.blue.withOpacity(0.7),
                          const Color(0xFF251A75),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.35),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.cyanAccent,
                              Colors.blue,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.7),
                              blurRadius: 35,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF101A48),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            Text(
              'JARVIS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Colors.cyanAccent.shade100,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              status,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // RESPONSE BOX
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF131C32),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.25),
                ),
              ),
              child: Text(
                response,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // VOICE BUTTON
            GestureDetector(
              onTap: toggleVoice,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: listening
                      ? Colors.redAccent
                      : Colors.cyanAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (listening
                              ? Colors.redAccent
                              : Colors.cyanAccent)
                          .withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  listening ? Icons.stop : Icons.mic,
                  color: Colors.black,
                  size: 35,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              listening ? 'STOP DEMO' : 'TAP TO TALK',
              style: const TextStyle(
                color: Colors.white60,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 25),

            // TEXT INPUT
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask Mitra anything...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF172139),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.cyanAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
