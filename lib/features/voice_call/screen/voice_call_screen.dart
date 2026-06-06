import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../contacts/model/chat_channel_model.dart';
import '../repository/voice_call_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common_snackbar.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.channel,
    required this.contactName,
  });

  final ChatChannelModel channel;
  final String contactName;

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final _repository = VoiceCallRepository();

  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isConnected = false;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    _repository.onJoinedChannel = () {
      if (mounted) {
        setState(() => _callStatus = 'Ringing...');
      }
    };

    _repository.onRemoteUserJoined = (uid) {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _callStatus = 'Connected';
        });
      }
    };

    _repository.onRemoteUserLeft = (_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _callStatus = 'Call ended';
        });
        Future.delayed(
          const Duration(seconds: 1),
          () { if (mounted) context.pop(); },
        );
      }
    };

    _repository.onError = (error) {
      if (mounted) CommonSnackbar.showError(context, error);
    };

    try {
      await _repository.init();
      await _repository.join(
        token: widget.channel.voiceCallToken ?? '',
        channelName: widget.channel.channelName ?? '',
      );
      // Default speaker on for voice calls
      await _repository.setSpeakerphone(enabled: true);
    } catch (e) {
      if (mounted) CommonSnackbar.showError(context, e.toString());
    }
  }

  Future<void> _toggleMute() async {
    final next = !_isMuted;
    await _repository.muteLocalAudio(mute: next);
    setState(() => _isMuted = next);
  }

  Future<void> _toggleSpeaker() async {
    final next = !_isSpeakerOn;
    await _repository.setSpeakerphone(enabled: next);
    setState(() => _isSpeakerOn = next);
  }

  Future<void> _endCall() async {
    await _repository.dispose();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Avatar
            CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.primary,
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact name
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Call status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isConnected)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  _callStatus,
                  style: TextStyle(
                    color: _isConnected ? Colors.greenAccent : Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Controls row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute
                  _CallControl(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onTap: _toggleMute,
                    active: _isMuted,
                  ),

                  // End call
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  // Speaker
                  _CallControl(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                    onTap: _toggleSpeaker,
                    active: _isSpeakerOn,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}

// ─── Control button ───────────────────────────────────────────────────────────

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withAlpha(230)
                  : Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? const Color(0xFF1A1A2E) : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
