# Mitra-ai
My Personal ai assistant 

import 'package:flutter/material.dart';

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

  late AnimationController animationController;
  final TextEditingController inputController =
      TextEditingController();

  bool listening = false;

  String status = "Your AI Assistant";
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void sendMessage() {
    String message = inputController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add({
        "type": "user",
        "text": message,
      });

      inputController.clear();
      status = "Thinking...";
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        messages.add({
          "type": "ai",
          "text": getReply(message),
        });

        status = "Your AI Assistant";
      });
    });
  }

  String getReply(String message) {
    String text = message.toLowerCase();

    if (text.contains("hello") ||
        text.contains("नमस्ते") ||
        text.contains("hi")) {
      return "Hello! I am Mitra AI. How can I help you?";
    }

    if (text.contains("name") ||
        text.contains("नाम")) {
      return "My name is Mitra AI, your smart assistant.";
    }

    if (text.contains("time") ||
        text.contains("समय")) {
      return "Current time: ${TimeOfDay.now().format(context)}";
    }

    if (text.contains("who are you") ||
        text.contains("तुम कौन")) {
      return "I am Mitra AI, your personal digital assistant.";
    }

    if (text.contains("jarvis")) {
      return "Yes! Jarvis is ready. Tell me your command.";
    }

    return "I received your message: $message. "
        "Connect an AI API to get intelligent answers.";
  }

  @override
  void dispose() {
    animationController.dispose();
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MITRA AI",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      Text(
                        "PERSONAL AI ASSISTANT",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const Icon(
                    Icons.settings,
                    color: Colors.cyanAccent,
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // AI ORB
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {

                double scale =
                    0.90 + animationController.value * 0.12;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    height: 190,
                    width: 190,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFB8FFFF),
                          Color(0xFF00BFFF),
                          Color(0xFF0645A5),
                          Color(0xFF050816),
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.45),
                          blurRadius: 45,
                          spreadRadius: 12,
                        ),
                      ],
                    ),

                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 65,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            Text(
              listening ? "LISTENING..." : "HEY, I'M MITRA",
              style: const TextStyle(
                fontSize: 19,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              listening ? "Waiting for your command" : status,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            // CHAT AREA
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {

                  final msg = messages[index];
                  bool isUser = msg["type"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      padding: const EdgeInsets.all(14),

                      constraints: const BoxConstraints(
                        maxWidth: 280,
                      ),

                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.blue.withOpacity(0.35)
                            : Colors.cyan.withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(16),

                        border: Border.all(
                          color: Colors.cyan.withOpacity(0.3),
                        ),
                      ),

                      child: Text(
                        msg["text"] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // QUICK COMMANDS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),

              child: Row(
                children: [
                  quickButton("Hello", "Hello"),
                  quickButton("Who are you?", "Who are you?"),
                  quickButton("Time", "Time"),
                  quickButton("Jarvis", "Jarvis"),
                ],
              ),
            ),

            // INPUT AREA
            Container(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [

                  IconButton(
                    onPressed: () {
                      setState(() {
                        listening = !listening;
                        status = listening
                            ? "Listening..."
                            : "Your AI Assistant";
                      });
                    },

                    icon: Icon(
                      listening ? Icons.mic : Icons.mic_none,
                      color: Colors.cyanAccent,
                      size: 28,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: inputController,

                      style: const TextStyle(
                        color: Colors.white,
                      ),

                      decoration: InputDecoration(
                        hintText: "Ask Mitra anything...",
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),

                        filled: true,
                        fillColor: const Color(0xFF111C35),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),

                      onSubmitted: (_) => sendMessage(),
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
                        size: 19,
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

  Widget quickButton(String title, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: OutlinedButton(
        onPressed: () {
          inputController.text = message;
          sendMessage();
        },

        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.cyanAccent,
          side: const BorderSide(
            color: Colors.cyanAccent,
          ),
        ),

        child: Text(title),
      ),
    );
  }
}
