import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:game_of_bitcoin/common/app_build_timestamp.dart';
import 'package:game_of_bitcoin/main.dart' show logger;

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Версия ${APP_VERSION_NUMBER} от ${APP_BUILD_DATE}'),
          TextButton(
            onPressed: _goForum,
            child: Text('Обсуждение на форуме',),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _goForum() async {
    //links to my topic
    final Uri url = Uri.parse('https://upad.ru/viewtopic.php?t=5631');
    if (!await launchUrl(url)) {
      logger.e('Не удалось открыть ссылку  $url');
    }
  }
}
