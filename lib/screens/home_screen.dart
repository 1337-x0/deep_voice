     ],
        ),
      ),
    );
  }
}import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/audio_provider.dart';

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
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Deep Voice',
              applicationVersion: '1.0.0',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRecordSection(audioProvider),
                const SizedBox(height: 30),
                _buildPitchSlider(audioProvider),
                const SizedBox(height: 20),
                _buildVolumeSlider(audioProvider),
                const SizedBox(height: 30),
                _buildPreviewSection(audioProvider),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [Colors.purpleAccent, Colors.blueAccent],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSection(AudioProvider provider) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('RECORD VOICE', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            IconButton(
              iconSize: 60,
              icon: Icon(
                provider.isRecording ? Icons.stop : Icons.mic,
                color: provider.isRecording ? Colors.red : Colors.purpleAccent,
              ),
              onPressed: () async {
                if (provider.isRecording) {
                  await provider.stopRecording();
                } else {
                  await provider.startRecording();
                }
              },
            ),
            Text(provider.isRecording ? 'Recording...' : 'Tap to record'),
          ],
        ),
      ),
    );
  }

  Widget _buildPitchSlider(AudioProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VOICE PITCH', style: TextStyle(fontSize: 16)),
        Slider(
          value: provider.pitchValue,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          label: 'Pitch: ${provider.pitchValue.toStringAsFixed(1)}',
          onChanged: provider.setPitch,
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(AudioProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VOLUME BOOST', style: TextStyle(fontSize: 16)),
        Slider(
          value: provider.volumeValue,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: 'Volume: ${provider.volumeValue.toStringAsFixed(1)}x',
          onChanged: provider.setVolume,
        ),
      ],
    );
  }

  Widget _buildPreviewSection(AudioProvider provider) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('PREVIEW', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await provider.processAudio();
                _confettiController.play();
              },
              child: const Text('PROCESS VOICE'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: provider.isPlaying ? provider.stopPlaying : provider.playProcessed,
                  child: Icon(provider.isPlaying ? Icons.stop : Icons.play_arrow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
