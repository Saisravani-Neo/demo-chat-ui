import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/chat/data/datasource/chat_remote_datasource.dart';
import 'features/chat/data/datasource/mock_chat_remote_datasource.dart';
import 'features/chat/data/services/agora_chat_service.dart';
import 'features/chat/data/services/api_client.dart';
import 'features/chat/domain/presentation/bloc/chat/chat_bloc.dart';
import 'features/chat/domain/presentation/bloc/chatbloc/chat_auth_bloc.dart';
import 'features/chat/domain/presentation/bloc/chatbloc/chat_auth_event.dart';
import 'features/chat/domain/presentation/bloc/chatbloc/chat_auth_state.dart';
import 'features/chat/domain/presentation/bloc/conversation/conversation_bloc.dart';
import 'features/chat/domain/presentation/bloc/group/group_bloc.dart';
import 'features/chat/domain/presentation/bloc/voice_call/voice_call_bloc.dart';
import 'features/chat/domain/presentation/screens/conversation_list_screen.dart';
import 'features/chat/domain/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecase/create_group_usecase.dart';
import 'features/chat/domain/usecase/end_voice_call_usecase.dart';
import 'features/chat/domain/usecase/get_agora_chat_token_usecase.dart';
import 'features/chat/domain/usecase/get_conversations_usecase.dart';
import 'features/chat/domain/usecase/login_agora_chat_usecase.dart';
import 'features/chat/domain/usecase/send_text_message_usecase.dart';
import 'features/chat/domain/usecase/send_voice_message_usecase.dart';
import 'features/chat/domain/usecase/start_voice_call_usecase.dart';

// Set to true to preview UI with mock data (no backend needed).
// Set to false and fill in the values below when your backend is ready.
const bool kUseMockData = true;

// TODO: Replace these with your actual values when kUseMockData = false
const String kBaseUrl = 'https://your-api-base-url.com';
const String kJwtToken = 'your-jwt-token';
const String kAgoraAppKey = 'your-agora-app-key';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final agoraChatService = AgoraChatService();

  if (!kUseMockData) {
    await agoraChatService.init(appKey: kAgoraAppKey);
  }

  final ChatRemoteDataSource remoteDataSource = kUseMockData
      ? MockChatRemoteDataSource()
      : ChatRemoteDataSource(
          ApiClient.create(baseUrl: kBaseUrl, jwtToken: kJwtToken));

  final repository = ChatRepositoryImpl(
    remoteDataSource: remoteDataSource,
    agoraChatService: agoraChatService,
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ChatRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = ChatAuthBloc(
              getTokenUseCase: GetAgoraChatTokenUseCase(repository),
              loginUseCase: LoginAgoraChatUseCase(repository),
            );
            if (!kUseMockData) bloc.add(ChatAuthStarted());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => ConversationBloc(
            getConversationsUseCase: GetConversationsUseCase(repository),
          ),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            sendTextMessageUseCase: SendTextMessageUseCase(repository),
            sendVoiceMessageUseCase: SendVoiceMessageUseCase(repository),
          ),
        ),
        BlocProvider(
          create: (_) => VoiceCallBloc(
            startVoiceCallUseCase: StartVoiceCallUseCase(repository),
            endVoiceCallUseCase: EndVoiceCallUseCase(repository),
          ),
        ),
        BlocProvider(
          create: (_) => GroupBloc(
            createGroupUseCase: CreateGroupUseCase(repository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Agora Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: kUseMockData
            ? const ConversationListScreen()
            : BlocBuilder<ChatAuthBloc, ChatAuthState>(
                builder: (context, state) {
                  if (state is ChatAuthLoading || state is ChatAuthInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is ChatAuthFailure) {
                    return Scaffold(
                      body:
                          Center(child: Text('Auth failed: ${state.message}')),
                    );
                  }

                  return const ConversationListScreen();
                },
              ),
      ),
    );
  }
}
