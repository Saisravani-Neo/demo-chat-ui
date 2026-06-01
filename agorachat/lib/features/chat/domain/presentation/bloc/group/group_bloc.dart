import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../usecase/create_group_usecase.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final CreateGroupUseCase createGroupUseCase;

  GroupBloc({
    required this.createGroupUseCase,
  }) : super(GroupInitial()) {
    on<CreateGroupEvent>(_onCreateGroup);
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    try {
      emit(GroupLoading());

      await createGroupUseCase(
        name: event.name,
        memberIds: event.memberIds,
      );

      emit(GroupCreated());
    } catch (e) {
      emit(GroupFailure(e.toString()));
    }
  }
}