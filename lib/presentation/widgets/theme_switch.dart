import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_of_bitcoin/bloc/bloc.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isExpanded;
  const ThemeSwitch({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, bool>(
      builder: (context, state) {
        return isExpanded?
        SwitchListTile(
          title: const Text('Тема',),
          value: state,
          onChanged: (bool value) {
            context.read<ThemeBloc>().add(ChangeTheme());
          },
          secondary: const Icon(Icons.lightbulb_outline),
        ) :Tooltip(
          preferBelow: true,
          message: 'Смена темы светлая/темная',
          child: IconButton(
            icon: state
                ? const Icon(Icons.dark_mode_outlined)
                : const Icon(Icons.light_mode_outlined),
            onPressed: () => context.read<ThemeBloc>().add(ChangeTheme()),
          ),
        );
      },
    );
  }
}

///Только иконка которая зависит от темы
class ThemeIcon extends StatelessWidget {
  const ThemeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, bool>(
      builder: (context, state) {
        return state
              ? const Icon(Icons.dark_mode_outlined)
              : const Icon(Icons.light_mode_outlined)
        ;
      },
    );
  }
}
