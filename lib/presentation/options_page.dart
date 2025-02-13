
import "package:path/path.dart" as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/data/data.dart';
import 'package:game_of_bitcoin/main.dart' show logger;

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final pathController = TextEditingController();
  String operationMessage = ''; //описание текущей длительной операции
  bool isBusy = false; //нажали Сохранить новый путь и запускается проверка корректности новой базы - вернуться пока нельзя

  final _pathFocus = FocusNode();
  final _saveButtonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    pathController.text = SharedPrefs.getString(Constants.DATABASE_PATH_KEY)?? '';
  }

  @override
  void dispose() {
    pathController.dispose();
    _pathFocus.dispose();
    _saveButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: isBusy? "Подождите, выполняется операция $operationMessage" : "Назад",
          onPressed: isBusy? null : () => Navigator.of(context).pop(),
        ),
        actions: [

        ],
      ),
      body: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          final bool shouldPop = !isBusy;
          if (context.mounted && shouldPop) {
            Navigator.pop(context);
          }
        },
        child: SizedBox(
          height: 250,
          child: SingleChildScrollView(
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.url,
                      controller: pathController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                        prefixIcon: Padding(
                          padding: EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                          child: FaIcon(
                            FontAwesomeIcons.folder,
                            size: 20,
                          ),
                        ),
                        hintText: "Путь к файлу с базой",
                        labelText: 'Путь к базе',
                        suffixIcon: IconButton(
                            onPressed: _selectFile,
                            icon: FaIcon(
                              FontAwesomeIcons.arrowPointer,
                              size: 20,
                            )),
                      ),
                    ),
                    SizedBox(height: 5),
                    Wrap(
                      spacing: 0.0,
                      runSpacing: 5.0,
                      children: [
                        Tooltip(
                          message:
                          "Сохранить данные ",
                          child: ElevatedButton(
                            focusNode: _saveButtonFocus,
                            onPressed: () async {
                              _save();
                            },
                            child: Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _save() async {
    try {
      setState(() {
        operationMessage = "Проверка корректности базы данных";
        isBusy = true;
      });

      FocusScope.of(context)
          .requestFocus(_saveButtonFocus); //set focus to ElevatedButton

      var path = pathController.text.trim();
      //И нужно сразу применить к AppDatabase
      await AppDatabase.open(path);

      if (!AppDatabase.isOpened) {
        _showError(
            "Не удалось применить путь к базе: ${AppDatabase.lastError}");
        return;
      }

      bool isOk = await SharedPrefs.setString(
          Constants.DATABASE_PATH_KEY, path);
      if (isOk) {
        _showSuccess(path);
      } else {
        logger.e("Failed saved to SharedPrefs path $path");
        _showError("Не удалось сохранить путь к базе по неизвестной причине");
      }

    } finally{
      setState(() {
        operationMessage = "";
        isBusy = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted){
      showScaffoldMessage(context: this.context, message: message, isError: true);
      setState(() {

      });
    }
  }

  void _showSuccess(String message) {
//Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.
    if (mounted){
      showScaffoldMessage(
          context: context, message: message, isError: false);
      setState(() {
      });
    }

  }

  void _selectFile() async {
    try{
      String? initialDirectory;
      if (pathController.text.isNotEmpty){
        initialDirectory = p.absolute(p.dirname(pathController.text)); //вот так работает правильно initialDirectory
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        initialDirectory: initialDirectory,
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['sqlite', 'db',],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        pathController.text = file.path?? '';
      } else {
        // User canceled the picker
      }
    } catch(ex){
      logger.e("_selectFile error: $ex");
    }
  }

}

