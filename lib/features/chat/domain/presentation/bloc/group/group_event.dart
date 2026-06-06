import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class CreateGroupEvent extends GroupEvent {
  final String name;
  final List<String> memberIds;

  const CreateGroupEvent({
    required this.name,
    required this.memberIds,
  });

  @override
  List<Object?> get props => [name, memberIds];
}