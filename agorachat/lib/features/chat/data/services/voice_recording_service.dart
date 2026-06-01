import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<String> startRecording() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
      ),
      path: path,
    );

    return path;
  }

  Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}