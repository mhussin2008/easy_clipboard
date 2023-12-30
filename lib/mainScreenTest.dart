import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataFile.dart';


class MainScreenTest extends StatefulWidget {
  const MainScreenTest({super.key});

  @override
  State<MainScreenTest> createState() => _MainScreenTestState();
}

class _MainScreenTestState extends State<MainScreenTest> {
  TextEditingController? txtController = TextEditingController();
  IconData? selectedIcon;
  bool loaded = false;





  @override
  Widget build(BuildContext context) {
    BoxDecoration deco =
    BoxDecoration(
        border: Border.all(
          color: Color(0xFF5511FF),
        ),
        borderRadius: BorderRadius.all(Radius.circular(20))
    );

    return Scaffold(
        appBar: AppBar(title: Center(child: const Text('Easy ClipBoard')),
          actions:

          [
            ElevatedButton(
              onPressed: () async {
                SharedPreferences sp = await SharedPreferences.getInstance();

                var captions = Items.map((e) => e.caption).toList();
                var links = Items.map((e) => e.link).toList();
                var icons = Items.map((e) => e.icon.toString()).toList();

                await sp.setStringList('captions', captions);
                await sp.setStringList('links', links);
                await sp.setStringList('icons', icons);
              },
              child: Text('Save'),
            ),

            ElevatedButton(
              onPressed: () async {
                SharedPreferences sp = await SharedPreferences.getInstance();
                loadData();
                // var captions= await sp.getStringList('captions') ;
                // var links=await sp.getStringList('links') ;
                // var icons=await sp.getStringList('icons') ;
                //
                // //Items.clear();
                // if(captions !=null){
                // for(int i=0;i<captions.length;i++){
                //   print(icons![i]);
                //   Items.add(ItemData(captions[i], links![i],
                //       Icons.add)
                //   );
                setState(() {

                });
                //}}

              },
              child: Text('Load'),
            )
          ],
        ),
        body:
        Center(
          child: Column(
              children: [
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
                        onPressed: () {
                          _addItem();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: Text('Add Item'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _pickIcon();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder()),
                        child: Text('Pick Icon'),
                      ),
                      (selectedIcon == null) ? Spacer() : Icon(
                        selectedIcon, size: 50,)


                    ]
                    ,
                  ),
                ),

                FutureBuilder(
                    future: loadData(),
                    builder: (BuildContext context,
                        AsyncSnapshot<void> snapshot) {
                      return (loaded == true) ?
                      Expanded(
                        child: SingleChildScrollView(child:
                        Column(
                            children:
                            Items.asMap().entries.map((e) => GestureDetector(
                              onHorizontalDragEnd: (endDetails){
                                Items.removeAt(e.key);
                                setState(() {

                                });
                              },
                              child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: deco,
                                            child: Text(e.value.caption
                                            ),
                                          ),

                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: deco,
                                              child: Text(e.value.link
                                              ),
                                            ),
                                          ),

                                          //Text(e.link),
                                          (e.value.icon == null)
                                              ? SizedBox(width: 10,)
                                              : Icon(e.value.icon, size: 40,)
                                        ],),
                            )).toList()

                            // Items.map((e) =>
                            //     GestureDetector(
                            //       onHorizontalDragEnd: (endDetails) {
                            //         // int _i=Items.indexWhere((element) =>
                            //         // element == e);
                            //         // Items.removeAt(_i
                            //         //     );
                            //         print('index=$_i');
                            //         setState(() {
                            //
                            //         });
                            //       },
                            //       onTap: () async {
                            //         await Clipboard.setData(
                            //             ClipboardData(text: e.link));
                            //       },
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment
                            //             .spaceEvenly,
                            //         children: [
                            //           Container(
                            //             padding: EdgeInsets.all(5),
                            //             decoration: deco,
                            //             child: Text(e.caption
                            //             ),
                            //           ),
                            //
                            //           Expanded(
                            //             child: Container(
                            //               padding: EdgeInsets.all(5),
                            //               decoration: deco,
                            //               child: Text(e.link
                            //               ),
                            //             ),
                            //           ),
                            //
                            //           //Text(e.link),
                            //           (e.icon == null)
                            //               ? SizedBox(width: 10,)
                            //               : Icon(e.icon, size: 40,)
                            //         ],),
                            //     )
                            //
                            //
                            // ).toList()

                        )),
                      ) : CircularProgressIndicator();
                    }
                )


              ]
          ),
        )
    );
  }





  _pickIcon() async {
    selectedIcon = await FlutterIconPicker.showIconPicker(
      context,
      adaptiveDialog: true,
      showTooltips: false,
      showSearchBar: true,
      iconPickerShape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      iconPackModes: [IconPack.material],
    );


    setState(() {

    });


  }


  void _addItem() async {
    ClipboardData? clippedText = await Clipboard.getData('text/plain');

    if(ClipboardData != null && clippedText != null){
      print(clippedText!.text.toString());
      print(Clipboard.kTextPlain);
      Items.add(ItemData( txtController!.text
          , clippedText!.text.toString()
          , (selectedIcon==null)? Icons.add: selectedIcon!)

      );
      txtController!.clear();
      setState(() {

      });


    }
  }

  Future<void> loadData() async {
    if(loaded==true) return;
    SharedPreferences sp=await SharedPreferences.getInstance();

    var captions= await sp.getStringList('captions') ;
    var links=await sp.getStringList('links') ;
    var icons=await sp.getStringList('icons') ;

    Items.clear();
    if(captions !=null){
      for(int i=0;i<captions.length;i++){
        print('icon = ${icons![i].toString()}');
        Items.add(ItemData(captions[i], links![i],
            Icons.add)
        );


      }
    }
    loaded=true;
  }
}

