
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:game_of_bitcoin/common/common.dart';
import 'package:game_of_bitcoin/domain/domain.dart';
import 'package:game_of_bitcoin/locator_service.dart' show sl;
import 'package:game_of_bitcoin/data/data.dart';
import 'package:game_of_bitcoin/main.dart' show logger;


Future<List<String>?>  _getAllFoundedAsyncFetch() async {
  final repo = sl<FoundRepository>();

  var eitherAll = await repo.getAllFounded();

  if (eitherAll.isLeft()) {
    var error = eitherAll.asLeft().message;
    logger.e("_getAllFoundedAsyncFetch", error:error);
    return null;
  } else {
    return eitherAll.asRight();
  }
}

class FoundedPage extends StatefulWidget {
  const FoundedPage({super.key});

  @override
  State<FoundedPage> createState() => _FoundedPageState();
}

class _FoundedPageState extends State<FoundedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Найденные ключи') ,
        actions: [
          if (kDebugMode) ... [
          IconButton(
              tooltip: "Добавить случайное значение ключа",
              onPressed: _addSampleKey,
              icon: Icon(Icons.add)
          ),
          ],
          IconButton(
              tooltip: "Очистить базу находок",
              onPressed: _clearFoundDatabase,
              icon: Icon(Icons.delete)
          )
        ],

      ),
      body: FutureBuilder<List<String>?>(
          future: _getAllFoundedAsyncFetch(),
          builder: (context, AsyncSnapshot<List<String>?> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text("error: ${snapshot.error.toString()}");
            }
            if (snapshot.data != null) {
              return getList(snapshot.data!);
            }
            return Text("Непредвиденная ошибка, смотри логи.");

          }
      ),
    );
  }

  Widget getList(List<String> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index]),
          onTap: () => _showKeyInfo(list[index]),
        );
      },
    );
  }

  void _showKeyInfo(String value) {

    BitcoinKey key = BitcoinKey.parseInt(value);
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
          //color: Colors.amber,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: const Text('Compressed P2PKH'),
                  subtitle: SelectableText('${key.p2PKHcompressed}'),
                  trailing: IconButton(
                    tooltip: "открыть blockchain.com",
                    onPressed: () {
                      _goExplorer(key.p2PKHcompressed);
                    },
                    icon: Icon(Icons.link),
                  ),
                ),
                ListTile(
                  title: const Text('Uncompressed P2PKH'),
                  subtitle: SelectableText('${key.p2PKHuncompressed}'),
                  trailing: IconButton(
                    tooltip: "открыть blockchain.com",
                    onPressed: () {
                      _goExplorer(key.p2PKHcompressed);
                    },
                    icon: Icon(Icons.link),
                  ),
                ),
                ListTile(
                  title: const Text('Segwit Address'),
                  subtitle: SelectableText('${key.segwitAddress}'),
                  trailing: IconButton(
                    tooltip: "открыть blockchain.com",
                    onPressed: () {
                      _goExplorer(key.p2PKHcompressed);
                    },
                    icon: Icon(Icons.link),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }

  void _clearFoundDatabase() async {
    var res =  await _askForClear();
    if (res != true) {
      return;
    }
    final repo = sl<FoundRepository>();

    var either = await repo.clearDatabase();

    if (either.isLeft()) {
      var error = either.asLeft().message;
      logger.e("_clearFoundDatabase", error:error);
      _showError(error);
      return;
    } else {
      if (either.asRight()){
        _showSuccess("База находок очищена");
      } else{
        _showError("Не удалось очистить базу находок");
      }
      return;
    }
  }

  Future<bool?> _askForClear() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Очистка базы'),
        content: Text('Вы действительно хотите очистить базу найденных ключей, продолжить?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('НЕТ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ДА'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {

    if (mounted){
      showScaffoldMessage(context: context, message: message, isError: true);
      setState(() {
      });
    }
  }

  void _showSuccess(String message) {
    if (mounted){
      showScaffoldMessage(
          context: context, message: message, isError: false);
      setState(() {
      });
    }
  }

  void _addSampleKey() async {
    final repo = sl<FoundRepository>();

    String key = getRandomKey();

    var either = await repo.addKey(key: key);

    if (either.isLeft()) {
      var error = either.asLeft().message;
      logger.e("_addSampleKey", error:error);
      _showError(error);
      return;
    } else {
      int id = either.asRight();
      if (id>0){
        _showSuccess("Ключ $key добавлен под индексом $id");
      } else{
        _showError("Не удалось добавить ключ $key");
      }
      return;
    }
  }

  void _goExplorer(String address) async {
    final Uri url = getBlockchainUri(address);
    if (!await launchUrl(url)) {
      _showError('Не удалось открыть ссылку  $url');
    }

  }

}



