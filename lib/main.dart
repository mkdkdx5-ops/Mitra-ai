
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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

  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  bool listening = false;
  bool hindi = true;
  bool speechReady = false;

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
    speech.stop();
    tts.stop();
    controller.dispose();
    input.dispose();
    super.dispose();
  }

  Future<void> speak(String text) async {
    try {
      await tts.setLanguage(hindi ? 'hi-IN' : 'en-IN');
      await tts.setSpeechRate(0.45);
      await tts.setVolume(1.0);
      await tts.speak(text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 'Voice output unavailable';
      });
    }
  }

  Future<void> toggleVoice() async {
    if (listening) {
      await speech.stop();
      if (!mounted) return;

      setState(() {
        listening = false;
        status = 'Ready';
      });
      return;
    }

    setState(() {
      status = 'Starting microphone...';
    });

    try {
      speechReady = await speech.initialize(
        onStatus: (value) {
          if (!mounted) return;

          if (value == 'done' || value == 'notListening') {
            setState(() {
              listening = false;
              status = 'Ready';
            });
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            listening = false;
            status = 'Speech error: ${error.errorMsg}';
            response = 'Please check microphone and speech recognition settings.';
          });
        },
      );

      if (!speechReady) {
        if (!mounted) return;

        setState(() {
          status = 'Speech recognition unavailable';
          response = 'Please check your Google speech recognition service.';
        });
        return;
      }

      final locales = await speech.locales();

      if (locales.isEmpty) {
        if (!mounted) return;
        setState(() {
          status = 'No speech language available';
        });
        return;
      }

      final preferred = hindi ? 'hi_IN' : 'en_IN';

      final matching = locales.where(
        (locale) =>
            locale.localeId.toLowerCase() ==
            preferred.toLowerCase(),
      );

      final language = matching.isNotEmpty
          ? matching.first.localeId
          : locales.firstWhere(
              (locale) => locale.localeId.toLowerCase().startsWith(
                    hindi ? 'hi' : 'en',
                  ),
              orElse: () => locales.first,
            ).localeId;

      await speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            input.text = result.recognizedWords;
            response = result.recognizedWords.isEmpty
                ? 'Listening...'
                : 'You said: ${result.recognizedWords}';
          });

          if (result.finalResult &&
              result.recognizedWords.trim().isNotEmpty) {
            final words = result.recognizedWords;

            setState(() {
              listening = false;
              status = 'Voice recognized';
              response = hindi
                  ? 'आपने कहा: $words\n\nMitra: मैंने आपकी बात सुन ली है।'
                  : 'You said: $words\n\nMitra: I heard you clearly.';
            });

            speak(
              hindi
                  ? 'मैंने आपकी बात सुन ली है।'
                  : 'I heard you clearly.',
            );
          }
        },
        localeId: language,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      if (!mounted) return;

      setState(() {
        listening = true;
        status = hindi ? 'सुन रहा हूँ...' : 'Listening...';
        response = hindi
            ? 'बोलिए, मैं सुन रहा हूँ।'
            : 'Speak now. I am listening.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        listening = false;
        status = 'Microphone error';
        response = e.toString();
      });
    }
  }

  Future<void> sendMessage() async {
    if (input.text.trim().isEmpty) return;

    final message = input.text.trim();

    setState(() {
      response = hindi
          ? 'आपने लिखा: $message\n\nMitra: आपका संदेश मिल गया है।'
          : 'You: $message\n\nMitra: I received your message.';
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
        child: SingleChildScrollView(
          child: Column(
            children: [
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

              const SizedBox(height: 20),

              const Text(
                'YOUR PERSONAL ASSISTANT',
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 3,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 35),

              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final scale = 1.0 + controller.value * 0.09;

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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

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

              const SizedBox(height: 35),

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
                listening ? 'STOP LISTENING' : 'TAP TO TALK',
                style: const TextStyle(
                  color: Colors.white60,
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
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
      ),
    );
  }
}
