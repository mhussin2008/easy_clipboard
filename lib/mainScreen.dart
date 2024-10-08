import 'dart:io';

import 'package:easy_clipboard/DialogScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataFile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController? txtController = TextEditingController();
  IconData? selectedIcon;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    BoxDecoration deco = BoxDecoration(
        border: Border.all(
          color: const Color(0xFF5511FF),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)));

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                await save_Data().then(
                  (onValue) {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    exit(0);
                  },
                );
              },
              icon: const Icon(size: 50, color: Colors.red, Icons.close)),
          title: const Center(
              child: Text(style: TextStyle(fontSize: 24), 'Easy ClipBoard')),
        ),
        body: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    //width: MediaQuery.of(context).size.width/2,
                    child: TextField(
                      controller: txtController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _addItem();
                    },
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            ),
            FutureBuilder(
                future: loadData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  return (loaded == true)
                      ? Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  children: Items.asMap()
                                      .entries
                                      .map((e) => GestureDetector(
                                            onHorizontalDragEnd:
                                                (endDetails) async {
                                              {
                                                print('ok');

                                                String result =
                                                    await showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            const DialogScreen(
                                                              msgComplement:
                                                                  'هذا العنصر',
                                                            ));
                                                //print(result);
                                                if (result == 'OK') {
                                                  //print('deleting');
                                                  Items.removeAt(e.key);
                                                }
                                              }
                                              setState(() {});
                                            },
                                            onTap: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: e.value.link));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor: Colors.cyan,
                                                content: Text(
                                                    "link copied to clipboard"),
                                              ));
                                            },
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration: deco,
                                                        child: Text(
                                                            e.value.caption),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: deco,
                                                          child: Text(
                                                              e.value.link),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 20,
                                                )
                                              ],
                                            ),
                                          ))
                                      .toList())),
                        )
                      : const CircularProgressIndicator();
                })
          ]),
        ));
  }

  Future<void> _addItem() async {
    ClipboardData? clippedText = await Clipboard.getData('text/plain');
    if (clippedText != null &&
        txtController?.text != '' &&
        txtController?.text != null) {
      print(clippedText.text.toString());
      print(Clipboard.kTextPlain);
      Items.add(ItemData(txtController!.text, clippedText.text.toString()));
      txtController!.clear();
      setState(() {});
    }
  }

  Future<void> loadData() async {
    if (loaded == true) return;
    SharedPreferences sp = await SharedPreferences.getInstance();

    var captions = sp.getStringList('captions');
    var links = sp.getStringList('links');
    //var icons=sp.getStringList('icons') ;

    Items.clear();

    if (captions != null && captions.isNotEmpty) {
      for (int i = 0; i < captions.length; i++) {
        Items.add(ItemData(captions[i], links![i]));
      }
    }
    loaded = true;
  }

  Future<void> save_Data() async {
    var captions = Items.map((e) => e.caption).toList();
    var links = Items.map((e) => e.link).toList();
    //var icons = Items.map((e) => e.icon.toString()).toList();
    SharedPreferences sp = await SharedPreferences.getInstance();
    await Future.wait([
      sp.setStringList('captions', captions),
      sp.setStringList('links', links),
      //sp.setStringList('icons', icons)
    ]);
  }
}
