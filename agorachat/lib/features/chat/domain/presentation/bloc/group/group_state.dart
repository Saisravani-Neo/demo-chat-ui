import 'package:equatable/equatable.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupCreated extends GroupState {}

class GroupFailure extends GroupState {
  final String message;

  const GroupFailure(this.message);

  @override
  List<Object?> get props => [message];
}