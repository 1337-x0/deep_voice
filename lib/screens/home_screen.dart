import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_voice_transformer/providers/audio_provider.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioProvider>(context, listen: false).initRecorder();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    Provider.of<AudioProvider>(context, listen: false).disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEEP VOICE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Deep Voice Transformer',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 VoiceFX Inc.',
                children: [
                  const SizedBox(height: 16),
                  const Text('Transform your voice to deep, crispy perfection!'),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRecordSection(audioProvider),
                const SizedBox(height: 30),
                _buildPitchSlider(audioProvider),
                const SizedBox(height: 20),
                _buildVolumeSlider(audioProvider),
                const SizedBox(height: 30),
                _buildPreviewSection(audioProvider),
                const SizedBox(height: 20),
                _buildSaveButton(audioProvider),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.purpleAccent,
                Colors.blueAccent,
                Colors.greenAccent,
                Colors.orangeAccent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // [Rest of the widget methods from previous code...]
  // Include all _buildRecordSection, _buildPitchSlider, 
  // _buildVolumeSlider, _buildPreviewSection, _buildSaveButton
  // methods exactly as shown in the previous complete code
}
