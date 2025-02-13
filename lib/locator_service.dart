import 'package:get_it/get_it.dart';

import 'package:game_of_bitcoin/data/found/found.dart'; //FoundSharedDatabase
import 'package:game_of_bitcoin/bloc/bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(
        () => ThemeBloc(),
  );

  sl.registerLazySingleton<ControllerBloc>(
        () => ControllerBloc(),
  );

  // FoundSharedDatabase
  final FoundSharedDatabase foundDatabase = await constructFoundDb();
  sl.registerLazySingleton<FoundSharedDatabase>(() => foundDatabase);
  // FoundRepository
  sl.registerLazySingleton<FoundRepository>(
        () => FoundRepository(database: foundDatabase,
    ),
  );

}
