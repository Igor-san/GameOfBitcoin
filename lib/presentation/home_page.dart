import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;

import 'package:game_of_bitcoin/bloc/bloc.dart';
import 'package:game_of_bitcoin/data/data.dart';
import 'package:game_of_bitcoin/presentation/presentation.dart';
import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/locator_service.dart';
import 'package:game_of_bitcoin/main.dart' show logger;
import 'package:url_launcher/url_launcher.dart';

enum _AppBarMenuItem {
  options,
  founded,
  theme,
  about,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isOpened = AppDatabase.isOpened;

    final breakpoint = Breakpoint.fromMediaQuery(context);

    bool isMobile = breakpoint.window<=WindowSize.small;

    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
          message: isOpened ? AppDatabase.currentPath : 'База не открыта',
          child: IconButton(
            icon: isOpened ? const Icon(Icons.power) : const Icon(Icons.power_off),
            onPressed: isOpened
                ?  _showDbPath
                : null,
          ),
        ),

        actions: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width*0.7,
            child: ControlPanel(),
          ),

          _getAppPopupMenu(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: GameOfBitcoin(
                    hideControls: isMobile,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getAppPopupMenu() {

    return BlocBuilder<ControllerBloc, ControllerState>(

      builder: (context, state) {
        bool isStopped = GameState.Stopped == state.gameState;
        return PopupMenuButton<_AppBarMenuItem>(
          enabled: isStopped,
          onSelected: (_AppBarMenuItem item) {

            switch (item) {
              case _AppBarMenuItem.options:
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OptionsPage()))
                    .then((value) => setState(() {}));
                break;
              case _AppBarMenuItem.founded:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FoundedPage()))
                    .then((value) => setState(() {}));
                break;
              case _AppBarMenuItem.theme:
                      context.read<ThemeBloc>().add(ChangeTheme());
                break;
              case _AppBarMenuItem.about:
                _goAbout();
                break;
              default:
                throw FormatException('Invalid');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_AppBarMenuItem>>[
            if (isDesktop) PopupMenuItem<_AppBarMenuItem>(
              value: _AppBarMenuItem.options,
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.gear,
                ),
                title: Text('Настройки'),
              ),
            ),
            PopupMenuItem<_AppBarMenuItem>(
              value: _AppBarMenuItem.founded,
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.trophy,
                ),
                title: const Text('Найденные'),
              ),
            ),
            PopupMenuItem<_AppBarMenuItem>(
              value: _AppBarMenuItem.theme,
              child: ListTile(
                leading: ThemeIcon(),
                title: const Text('Тема'),
              ),
            ),
            PopupMenuItem<_AppBarMenuItem>(
              value: _AppBarMenuItem.about,
              child: ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.houseUser,
                ),
                title: const Text('О GOB ${APP_VERSION_NUMBER}'),
              ),
            ),
          ],
        );
      }
    );
  }

  void _showDbPath() async {
    //!!! если большая база - может быть длительная задержка подсчета!
    bool isStopped = GameState.Stopped == sl<ControllerBloc>().state.gameState;

    if (!isStopped) { //во время игры ни к чему дергать базу
      logger.d("Игра еще идет");
      return;
    }

    var count = await AppDatabase.repo.getTableSize('address');

    if (mounted){ //Избежать предупреждения Don't use 'BuildContext's across async gaps.
      showScaffoldMessage(
        context: context,
        message: "${AppDatabase.currentPath} - $count записей",
        isError: false,
      );
    }

  }

  Future _goAbout() async {
     await showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
          child: const AboutWidget(),
      ),
    );
  }
}
