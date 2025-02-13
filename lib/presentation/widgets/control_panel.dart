import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_of_bitcoin/locator_service.dart';
import 'package:game_of_bitcoin/bloc/bloc.dart';

const double _iconSize = 15.0;

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControllerBloc, ControllerState>(
      builder: (context, state) {
        bool isPlaying =
            GameState.Playing == sl<ControllerBloc>().state.gameState;

        return Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
          child: Row(
            spacing: 0,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: "Ключ текущего состояния",
                      child: IconButton(
                        onPressed: isPlaying
                            ? null
                            : () => sl<ControllerBloc>().add(ControllerEvent(
                                gameState:
                                    GameState.GetKey)), //при работе отключаем,
                        icon: FaIcon(
                          FontAwesomeIcons.key,
                          size: _iconSize,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: VerticalDivider(),
                    ),
                    Tooltip(
                      message: "Случайные ячейки",
                      child: IconButton(
                        onPressed: isPlaying
                            ? null
                            : () => sl<ControllerBloc>().add(
                                ControllerEvent(gameState: GameState.Random)),
                        icon: const FaIcon(
                          FontAwesomeIcons.dice,
                          size: _iconSize,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: isPlaying ? "Остановить" : "Запустить",
                      child: IconButton(
                        onPressed: () => {
                          isPlaying
                              ? sl<ControllerBloc>().add(
                                  ControllerEvent(gameState: GameState.Stop))
                              : sl<ControllerBloc>().add(
                                  ControllerEvent(gameState: GameState.Start))
                        },
                        icon: FaIcon(
                          isPlaying
                              ? FontAwesomeIcons.stop
                              : FontAwesomeIcons.play,
                          size: _iconSize,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: "Очистить поле",
                      child: IconButton(
                        onPressed: isPlaying
                            ? null
                            : () => sl<ControllerBloc>().add(
                                ControllerEvent(gameState: GameState.Clear)),
                        icon: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: _iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
