import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'locator_service.dart' as di;
import 'common/common.dart';
import 'data/data.dart';
import 'utils/utils.dart';
import 'presentation/presentation.dart';
import 'bloc/bloc.dart';

late Logger logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  logger = await createLogger();

  await di.init();

  await SharedPrefs.init();

  await _openDatabase(); //нужно попробовать открыть базу Windows, Linux , в Android and Web копируем демо

  await _setupWindow();

  runApp(const MyApp());
}

_openDatabase() async {
  if (isDesktop) {
    String path = SharedPrefs.getString(Constants.DATABASE_PATH_KEY) ?? '';
    if (path.isNotEmpty) {
      //в Десктопе уже задали путь к базе - открываем ее
      await AppDatabase.open(path);
      return;
    }
  }

  await AppDatabase.open('');
}

_setupWindow() async {
  if (isDesktop) {
    await windowManager
        .ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Constants.NORMAL_SIZE,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (BuildContext context) => ThemeBloc()
            ..add(
              SetInitialTheme(),
            ),
        ),
        BlocProvider<ControllerBloc>(
          create: (BuildContext context) => di.sl<ControllerBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, bool>(builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Game of Bitcoin',
          theme: ThemeData.light().copyWith(
            extensions: <ThemeExtension<dynamic>>[
              const MyColors(
                brandColor: Color(0xFF1E88E5),
                errorColor: Color(0xFFE53935),
                successColor: Colors.green,
              ),
            ],
          ),
          darkTheme: ThemeData.dark().copyWith(
            extensions: <ThemeExtension<dynamic>>[
              const MyColors(
                brandColor: Color(0xFF90CAF9),
                errorColor: Color(0xFFEF9A9A),
                successColor: Colors.greenAccent,
              ),
            ],
          ),
          themeMode: state ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      }),
    );
  }
}
