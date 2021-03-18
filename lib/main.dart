import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
//when connect auth:
//final FirebaseUser user = await _firebaseAuth.currentUser();
//return await FirebaseDatabase.instance.reference().child('user').equalTo(user.uid);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool start = true;
  List<bool> _selections = List.generate(2, (int index) => !(index==1));
  List<String> dbResultSet;
  var tempSearchStore = [];
  var discoverStore = [];
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future getPageInfo() async 
  {
    return this._memoizer.runOnce(() async 
    {
      var ref = await FirebaseDatabase.instance.reference().child('Customers/1234567890/Searches/');
      
      ref.once().then((DataSnapshot snapshot) async {
        
        dbResultSet = snapshot.value.cast<String>();

        await FirebaseFirestore.instance.collection("Products").where('Keys', arrayContainsAny: dbResultSet).get().then((querySnapshot) => 
        {
            for (int i = 0; i < querySnapshot.docs.length; i++) {
                tempSearchStore.add(querySnapshot.docs.elementAt(i).data()),
                setState(() {
                  discoverStore.add(tempSearchStore[i]);
                  print("From:");
                  print(discoverStore[i]);
                })
            }   
        });
      });
    });  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(children: <Widget>[
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            child:ToggleButtons(
              children: <Widget>[
                Icon(Icons.ac_unit),
                Icon(Icons.call),
              ],
              isSelected: _selections,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < _selections.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      print("Running here?");
                      _selections[buttonIndex] = true;
                      getPageInfo();
                    } else {
                      _selections[buttonIndex] = false;
                    }
                  }
                });
              },
            ),
        ),
      FutureBuilder(
      future: getPageInfo(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && discoverStore.isNotEmpty) {
        return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.all(2),
            child:GridView.count(
              padding: EdgeInsets.only(left: 4.0, right: 4.0),
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              primary: false,
              shrinkWrap: true,
              children: discoverStore.map((element) {
              return buildResultCard(element);
            }).toList()
          ));
        } else {
          return Center(
            child: CircularProgressIndicator()
          );
        }
      }),
    ],),
  );
}
}

Widget buildResultCard(data) {
  return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Container(
          child: Center(
        child: Text(
          data['Name'],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
      )));
}
