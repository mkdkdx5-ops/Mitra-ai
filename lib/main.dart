
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
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
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  late AnimationController animation;
  bool listening = false;
  bool hindi = true;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    setupVoice();
  }

  Future<void> setupVoice() async {
    await speech.initialize();
    await tts.setLanguage('hi-IN');
    await tts.setSpeechRate(0.45);
  }

  Future<void> speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  String brain(String question) {
    String q = question.toLowerCase().trim();

    if (q.contains('hello') || q.contains('नमस्ते') ||
        q.contains('हेलो') || q.contains('hi')) {
      return hindi ? 'नमस्ते! मैं मित्रा हूँ। आपकी क्या मदद करूँ?'
          : 'Hello! I am Mitra. How can I help you?';
    }

    if (q.contains('तुम कौन') || q.contains('who are you')) {
      return hindi ? 'मैं मित्रा AI हूँ, आपका वॉइस असिस्टेंट।'
          : 'I am Mitra AI, your voice assistant.';
    }

    if (q.contains('समय') || q.contains('time')) {
      return 'अभी समय ${TimeOfDay.now().format(context)} है।';
    }

    if (q.contains('तारीख') || q.contains('date')) {
      final now = DateTime.now();
      return 'आज ${now.day}-${now.month}-${now.year} है।';
    }

    if (q.contains('भारत की राजधानी') ||
        q.contains('capital of india')) {
      return 'भारत की राजधानी नई दिल्ली है।';
    }

    if (q.contains('धन्यवाद') || q.contains('thank')) {
      return hindi ? 'आपका स्वागत है!' : 'You are welcome!';
    }

    if (q.contains('तुम्हारा नाम') || q.contains('your name')) {
      return 'मेरा नाम मित्रा AI है।';
    }

    if (q.contains('बाय') || q.contains('bye')) {
      return 'अलविदा! फिर मिलेंगे।';
    }

    return hindi
        ? 'मैंने आपका सवाल सुना है। अभी मेरा बेसिक ब्रेन है। इस सवाल का जवाब मेरे पास उपलब्ध नहीं है।'
        : 'I heard your question. My basic brain does not have an answer for this yet.';
  }

  void addMessage(String question, String answer) {
    setState(() {
      messages.add({'you': question, 'jarvis': answer});
    });
  }

  Future<void> sendMessage() async {
    String question = controller.text.trim();
    if (question.isEmpty) return;

    controller.clear();
    String answer = brain(question);
    addMessage(question, answer);
    await speak(answer);
  }

  Future<void> toggleMic() async {
    if (listening) {
      await speech.stop();
      setState(() => listening = false);
      return;
    }

    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => listening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => listening = false);
      },
    );

    if (!available) {
      await speak('माइक्रोफोन उपलब्ध नहीं है।');
      return;
    }

    setState(() => listening = true);

    await speech.listen(
      localeId: hindi ? 'hi_IN' : 'en_IN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          controller.text = result.recognizedWords;
          if (result.finalResult) {
            sendMessage();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    animation.dispose();
    controller.dispose();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10182B),
        title: const Text(
          'MITRA AI',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.cyanAccent),
            onPressed: () {
              setState(() => hindi = !hindi);
              speak(hindi ? 'हिंदी भाषा चुनी गई।' : 'English selected.');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              double scale = 1 + animation.value * 0.12;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.cyanAccent,
                        Colors.blue,
                        Color(0xFF10182B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 35,
                        spreadRadius: 8,
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
          const SizedBox(height: 12),
          Text(
            listening ? 'Listening...' : 'I AM MITRA AI',
            style: const TextStyle(
              color: Colors.cyanAccent,
              letterSpacing: 3,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item = messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Card(
                        color: const Color(0xFF173653),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('You: ${item['you']}'),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Card(
                        color: const Color(0xFF123B40),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('Mitra: ${item['jarvis']}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: hindi
                          ? 'मित्रा से कुछ पूछें...'
                          : 'Ask Mitra something...',
                      filled: true,
                      fillColor: const Color(0xFF18243B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.cyanAccent),
                ),
                IconButton(
                  onPressed: toggleMic,
                  icon: Icon(
                    listening ? Icons.mic : Icons.mic_none,
                    color: Colors.cyanAccent,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
