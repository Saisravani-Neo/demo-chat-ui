import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraRtcService {
  RtcEngine? _engine;

  RtcEngine? get engine => _engine;

  Future<void> init({
    required String appId,
    required void Function() onTokenWillExpire,
    required void Function(int remoteUid) onUserJoined,
    required void Function(int remoteUid) onUserOffline,
  }) async {
    _engine = createAgoraRtcEngine();

    await _engine!.initialize(
      RtcEngineContext(appId: appId),
    );

    await _engine!.enableAudio();

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onTokenPrivilegeWillExpire: (c, s) {
          onTokenWillExpire();
        },
        onUserJoined: (c, remoteUid, e) {
          onUserJoined(remoteUid);
        },
        onUserOffline: (c, remoteUid, r) {
          onUserOffline(remoteUid);
        },
      ),
    );
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    await _engine?.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> renewToken(String token) async {
    await _engine?.renewToken(token);
  }

  Future<void> mute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> speaker(bool enabled) async {
    await _engine?.setEnableSpeakerphone(enabled);
  }

  Future<void> leave() async {
    await _engine?.leaveChannel();
  }

  Future<void> dispose() async {
    await _engine?.release();
  }
}