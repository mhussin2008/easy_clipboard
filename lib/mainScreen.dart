import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dataFile.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController? txtController=TextEditingController();
  IconData? selectedIcon;
  @override
  Widget build(BuildContext context) {

  BoxDecoration deco=BoxDecoration(
  color: Colors.cyan,
  borderRadius: BorderRadius.only(
    topLeft: Radius.elliptical(20, 10),
    bottomRight: Radius.elliptical(10, 20),
  ),
  border: Border.all(
    color: Colors.black,
    width: 3.0,
  ),
);

    return  Scaffold(
      appBar: AppBar(title: Center(child: const Text('Easy ClipBoard')),
        actions:

           [
          ElevatedButton(
          onPressed: () async{
            SharedPreferences sp=await SharedPreferences.getInstance();

            var captions=Items.map((e) => e.caption).toList();
            var links=Items.map((e) => e.link).toList();
            var icons=Items.map((e) => e.icon.toString()).toList();

            await sp.setStringList('captions', captions);
            await sp.setStringList('links', links);
            await sp.setStringList('icons', icons);

          },
          child: Text('Save'),
        ),

          ElevatedButton(
            onPressed: () async{
              SharedPreferences sp=await SharedPreferences.getInstance();

              var captions= await sp.getStringList('captions') ;
              var links=await sp.getStringList('links') ;
              var icons=await sp.getStringList('icons') ;

              Items.clear();
              if(captions !=null){
              for(int i=0;i<captions.length;i++){
                print(icons![i]);
                Items.add(ItemData(captions[i], links![i],
                    Icons.add)
                );
                setState(() {

                });
              }}

            },
            child: Text('Load'),
          )],
      ),
      body: Center(
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
                 style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                 child: Text('Add Item'),
               ) ,
               ElevatedButton(
                 onPressed: () {
                   _pickIcon();

                 },
                 style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                 child: Text('Pick Icon'),
               ),
               (selectedIcon==null)? Spacer():Icon(selectedIcon,size: 50,)



             ]
        ,
           ),
         ),

          Expanded(
            child: SingleChildScrollView(child:
                Column(
            children :Items.map((e) =>
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                  //width: 150.0,
                      //height: 100.0,
                      decoration:deco,
                  child: Text(e.caption
                                  ),
                    ),

                Container(
                  //width: 150.0,
                  //height: 100.0,
                  decoration: deco,
                  child: Text(e.link
                  ),
                ),

                    //Text(e.link),
                    (e.icon==null)? Spacer():Icon(e.icon,size: 50,)
                  ],)
            
            
            ).toList()
            
                )),
          )


        ]
        ),
      ),

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
    if(ClipboardData != null){
      Items.add(ItemData( txtController!.text
          , clippedText!.text.toString()
          , (selectedIcon==null)? Icons.add: selectedIcon!)

      );
          setState(() {

            });


    }
  }
}
