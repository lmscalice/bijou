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
        
        dbResultSet = snapshot.value.keys.cast<String>().toList();

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
                Icon(Icons.public),
                Icon(Icons.person),
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
              crossAxisCount: 1,
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
  List<String> boards;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future fetchUserInfo() async 
  {
    return _memoizer.runOnce(() async 
    {
      print("GET HERE?");
      var ref = FirebaseDatabase.instance.reference().child('Customers/1234567890/Boards/');
      
      ref.once().then((DataSnapshot snapshot) async {
        print("HOW ABOUT HERE?");
        boards = snapshot.value.keys.cast<String>().toList();
        boards.add("New Board");
        print(boards);
      });
    });
  }
  return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                    child: Image.network(data['Image'],
                        height: 315,
                        width: 3150,
                        fit:BoxFit.contain,
                    ),
                ),
                const Divider(
                  height:0,
                  thickness: 1,
                ),
                
                ButtonBar(

                  alignment: MainAxisAlignment.spaceBetween,
                  buttonHeight: 10,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(data['Name'],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ),

                    FloatingActionButton(
                      onPressed: () => fetchUserInfo(),//{print(data['y']);} ,
                      child:FutureBuilder(
                          future: fetchUserInfo(),
                          builder: (ctx, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done){
                            return PopupMenuButton(
                                initialValue: 2,
                                child: Center(
                                child: Icon(Icons.add)),
                                itemBuilder: (context) {
                                  return List.generate(boards.length, (index) {
                                    print("HERE NOW");
                                    return PopupMenuItem(
                                      value: index,
                                      child: Text(boards[index].toString()),
                                    );
                                  });
                                },
                                onSelected: (int index) async {
                                    if (index != boards.length-1)
                                    {
                                        String board_chosen = boards[index];
                                        String pin = data['id'];
                                        FirebaseDatabase.instance.reference().child('Customers/1234567890/Boards/$board_chosen/').update({
                                          '$pin':'true'
                                        });
                                    }
                                    /*else
                                    {
                                      return 
                                    }
                                    print('index is $index');*/
                                },
                              );
                          }
                          else
                          {
                            print("SKIPPING?");
                          }
                      }),

                      backgroundColor: Colors.red,
                    )
                  ],
                ),
              ]
            )
);
          
}
