
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_of_bitcoin/common/common.dart' show Constants, SharedPrefs;

abstract class ThemeEvent {}

class SetInitialTheme extends ThemeEvent {}

class ChangeTheme extends ThemeEvent {}

//https://sudorealm.com/blog/how-to-switch-themes-in-flutter-using-bloc
class ThemeBloc extends Bloc<ThemeEvent, bool> {
  ThemeBloc() : super(false) {

    // execute this event when the app starts
    on<SetInitialTheme>(
          (event, emit) async {
        bool hasThemeDark = await isDark();
        emit(hasThemeDark);
      },
    );

    on<ChangeTheme>(
          (event, emit) async {
        bool hasThemeDark = await isDark();

        emit(!hasThemeDark);
        setTheme(!hasThemeDark);
      },
    );
  }
}

Future<bool> isDark() async {
  return SharedPrefs.getBool(Constants.IS_DARK_THEME_NAME) ?? false;
}

Future<void> setTheme(bool isDark) async {
  SharedPrefs.setBool(Constants.IS_DARK_THEME_NAME, isDark);
}