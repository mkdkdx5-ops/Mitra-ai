
import 'package:flutter/material.dart';

void main() {
  runApp(const JarvisAI());
}

class JarvisAI extends StatelessWidget {
  const JarvisAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JARVIS AI',
      theme: ThemeData.dark(),
      home: const JarvisHome(),
    );
  }
}

class JarvisHome extends StatefulWidget {
  const JarvisHome({super.key});

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  final TextEditingController input = TextEditingController();

  String status = 'YOUR PERSONAL AI';
  final List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  String getReply(String message) {
    String m = message.toLowerCase();

    if (m.contains('hello') || m.contains('hi') ||
        m.contains('नमस्ते')) {
      return 'Hello! I am Jarvis. How can I help you?';
    }

    if (m.contains('your name') || m.contains('नाम')) {
      return 'My name is JARVIS AI.';
    }

    if (m.contains('who are you') || m.contains('कौन हो')) {
      return 'I am your personal digital assistant.';
    }

    if (m.contains('time') || m.contains('समय')) {
      return 'Current time: ${TimeOfDay.now().format(context)}';
    }

    if (m.contains('date') || m.contains('तारीख')) {
      return 'Today: ${DateTime.now().day}/'
          '${DateTime.now().month}/${DateTime.now().year}';
    }

    if (m.contains('jarvis')) {
      return 'Yes! Jarvis is ready for your command.';
    }

    return 'I received your message. Connect an AI service '
        'to get intelligent answers.';
  }

  void sendMessage() {
    String text = input.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'You',
        'text': text,
      });

      input.clear();
      status = 'THINKING...';
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        messages.add({
          'sender': 'Jarvis',
          'text': getReply(text),
        });

        status = 'SYSTEM ONLINE';
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030814),

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.blur_on,
                    color: Colors.cyanAccent,
                    size: 35,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JARVIS AI',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'PERSONAL INTELLIGENCE SYSTEM',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.settings,
                    color: Colors.cyanAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GLOWING AI BALL
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                double scale =
                    0.92 + controller.value * 0.12;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    height: 190,
                    width: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF53E8FF),
                          Color(0xFF0077FF),
                          Color(0xFF07142F),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 50,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 65,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'HELLO, I AM JARVIS',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              status,
              style: const TextStyle(
                color: Colors.white54,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 20),

            // CHAT
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text(
                        'How can I help you today?',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        bool user = msg['sender'] == 'You';

                        return Align(
                          alignment: user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(14),
                            constraints: const BoxConstraints(
                              maxWidth: 290,
                            ),
                            decoration: BoxDecoration(
                              color: user
                                  ? Colors.blue.withOpacity(0.25)
                                  : Colors.cyan.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyan.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['sender']!,
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  msg['text']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // INPUT
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Icon(
                    Icons.mic_none,
                    color: Colors.cyanAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: input,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask Jarvis anything...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111C35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor: Colors.cyanAccent,
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
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
