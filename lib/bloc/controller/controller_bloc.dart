import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum GameState {
  Stopped,
  Playing,
  Start,
  Stop,
  Clear,
  GetKey,
  Random,
}

class ControllerBloc extends Bloc<ControllerEvent, ControllerState> {

  ControllerBloc() : super(ControllerState.empty()) {
     on<ControllerEvent>(
          (event, emit) async {

            if (event.gameState == GameState.GetKey) {
              emit(GetKeyState());
            } else if (event.gameState == GameState.Random) {
              emit(GetRandomState());
            } else if (event.gameState == GameState.Clear) {
              emit(ClearState());
            } else {
            emit(ControllerState(gameState: event.gameState));
            }

      },
    );
  }

}

class ControllerEvent extends Equatable {
  final GameState gameState;
  const ControllerEvent({required this.gameState,});

  factory ControllerEvent.empty(){
    return ControllerEvent(gameState: GameState.Stopped);
  }

  @override
  List<Object?> get props => [gameState,];
}

class ControllerState extends Equatable {
  final GameState gameState;
  const ControllerState({required this.gameState});

  factory ControllerState.empty(){
    return ControllerState(gameState: GameState.Stopped);
  }

  @override
  List<Object?> get props => [gameState,];
}

///Иначе повторный вызов GetKey не будет эмитировать событие, делаем его уникальным
class GetKeyState extends ControllerState {
  final String _id;

  GetKeyState({super.gameState= GameState.GetKey}) : _id = DateTime.now().toIso8601String();
  @override
  List<Object> get props => [_id];

}

class GetRandomState extends ControllerState {
  final String _id;

  GetRandomState({super.gameState= GameState.Random}) : _id = DateTime.now().toIso8601String();
  @override
  List<Object> get props => [_id];
}

class ClearState extends ControllerState {
  final String _id;

  ClearState({super.gameState= GameState.Clear}) : _id = DateTime.now().toIso8601String();
  @override
  List<Object> get props => [_id];
}