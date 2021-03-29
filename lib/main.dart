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

  Future initially() async 
  {
    return this._memoizer.runOnce(() async 
    {
              var ref = await FirebaseDatabase.instance.reference().child('Customers/1234567890/Searches/');
        ref.once().then((DataSnapshot snapshot) async {
          
          dbResultSet = snapshot.value.keys.cast<String>().toList();

          await FirebaseFirestore.instance.collection("Products").where('Keys', arrayContainsAny: dbResultSet).get().then((querySnapshot) => 
          {
              for (int i = 0; i < querySnapshot.docs.length; i++) {
                  //tempSearchStore.add(querySnapshot.docs.elementAt(i).data()),
                  setState(() {
                    discoverStore.add(querySnapshot.docs.elementAt(i).data());
                    //print("From:");
                    //print(discoverStore[i]);
                  })
              }   
          });

          await FirebaseFirestore.instance.collection("Businesses").where('SearchKey', arrayContainsAny: dbResultSet).get().then((querySnapshot) => 
          {
              for (int i = 0; i < querySnapshot.docs.length; i++) {
                  //tempSearchStore.add(querySnapshot.docs.elementAt(i).data()),
                  setState(() {
                    discoverStore.add(querySnapshot.docs.elementAt(i).data());
                    //print("From:");
                    //print(discoverStore[i]);
                  })
              }   
          });

        });

    });
  }

  Future getPageInfo() async 
  {
    //return this._memoizer.runOnce(() async 
    //{
      print(_selections[0]);
      print(_selections[1]);
      discoverStore = [];
      tempSearchStore = [];

      if (_selections[0])
      {
        var ref = await FirebaseDatabase.instance.reference().child('Customers/1234567890/Searches/');
        ref.once().then((DataSnapshot snapshot) async {
          
          dbResultSet = snapshot.value.keys.cast<String>().toList();

          await FirebaseFirestore.instance.collection("Products").where('Keys', arrayContainsAny: dbResultSet).get().then((querySnapshot) => 
          {
              for (int i = 0; i < querySnapshot.docs.length; i++) {
                  //tempSearchStore.add(querySnapshot.docs.elementAt(i).data()),
                  setState(() {
                    discoverStore.add(querySnapshot.docs.elementAt(i).data());
                    //print("From:");
                    //print(discoverStore[i]);
                  })
              }   
          });

          await FirebaseFirestore.instance.collection("Businesses").where('SearchKey', arrayContainsAny: dbResultSet).get().then((querySnapshot) => 
          {
              for (int i = 0; i < querySnapshot.docs.length; i++) {
                  //tempSearchStore.add(querySnapshot.docs.elementAt(i).data()),
                  setState(() {
                    discoverStore.add(querySnapshot.docs.elementAt(i).data());
                    //print("From:");
                    //print(discoverStore[i]);
                  })
              }   
          });

        });
      }
      else
      {
        print("FOLLOWING PAGE RUNNING");
        var ref = await FirebaseDatabase.instance.reference().child('Customers/1234567890/Following/');
        ref.once().then((DataSnapshot snapshot) async {
          
          dbResultSet = snapshot.value.keys.cast<String>().toList();
          var length = dbResultSet.length;
          print("GOT FOLLOWERS");
        
          for (int i =0; i<length; i++)
          {
            var currfol = dbResultSet[i];
            print("CURR FOLLOWER:" + currfol);
            var ref1 = await FirebaseDatabase.instance.reference().child('Customers/$currfol/Boards/');
            ref1.once().then((DataSnapshot snapshot) async {
              
              var dbResultSetBoards = snapshot.value.keys.cast<String>().toList();
              var num_boards = dbResultSetBoards.length;
              print("GOT BOARDS");

              for (int j =0; j<num_boards; j++)
              {
                var currBoard = dbResultSetBoards[j];
                print("CURR BOARD:" + currBoard);
                var ref2 = await FirebaseDatabase.instance.reference().child('Customers/$currfol/Boards/$currBoard/Product');
                print("CURR REF:" + ref1.toString());
                ref2.once().then((DataSnapshot snapshot) async {
                  print("PRODS:" + snapshot.value.keys.toString());
                  var dbResultSetProds = snapshot.value.keys.cast<String>().toList();
                  var num_pins = dbResultSetProds.length;
                  print("GOT PROD PINS");

                  //tempSearchStore = [];
                  for (int k =0; k<num_pins; k++)
                  {
                    await FirebaseFirestore.instance.collection("Products").doc(dbResultSetProds[k]).get().then((querySnapshot) => 
                    {
                      print("CURR PROD:" + querySnapshot.data().toString() ),
                      //tempSearchStore.add(querySnapshot.data()),
                      setState(() {
                        discoverStore.add(querySnapshot.data());
                        //print("From:");
                        //print(discoverStore[k]);
                      })
                    });
                  }
                  //tempSearchStore = []; 
                });  

                var ref3 = await FirebaseDatabase.instance.reference().child('Customers/$currfol/Boards/$currBoard/Business');
                ref3.once().then((DataSnapshot snapshot) async {
                  print("BUS:" + snapshot.value.keys.toString());
                  var dbResultSetProds = snapshot.value.keys.cast<String>().toList();
                  var num_pins = dbResultSetProds.length;
                  print("GOT BUS PINS");

                  for (int k =0; k<num_pins; k++)
                  {
                    await FirebaseFirestore.instance.collection("Businesses").doc(dbResultSetProds[k]).get().then((querySnapshot) => 
                    {
                      print("CURR PROD:" + querySnapshot.data().toString() ),
                      //tempSearchStore.add(querySnapshot.data()),
                      setState(() {
                        discoverStore.add(querySnapshot.data());
                        //print("From:");
                        //print(discoverStore[k]);
                      })
                    });
                  }
                  //tempSearchStore = [];
                });
             }
            });

          }
          
        });
      }
    //});  
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
      future: initially(),
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
        } //else {
          return Center(
            child: CircularProgressIndicator()
          );
        //}
      }),
    ],),
  );
}
}

Widget buildResultCard(data) {
  List<String> boards;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final _formKey = GlobalKey<FormState>();
  var textValue = "";

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
                    child: Image.network(data['Image1'],
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
                                    else
                                    {
                                      showDialog<void>(
                                      context: ctx,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Stack(
                                            overflow: Overflow.visible,
                                            children: <Widget>[
                                              Positioned(
                                                right: -40.0,
                                                top: -40.0,
                                                child: InkResponse(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: CircleAvatar(
                                                    child: Icon(Icons.close),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Text("Enter Board Name")
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        onChanged :(v){
                                                          textValue =  v;
                                                        }),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: RaisedButton(
                                                        child: Text("Create Board and Add Pin"),
                                                        onPressed: () {
                                                          if(textValue.isEmpty)
                                                          {
                                                            showDialog<void>(
                                                            context: ctx,
                                                            //print("EMPTY");
                                                            builder: (BuildContext context) { 
                                                            return AlertDialog(
                                                              title: Text('Please Enter A Board Name'),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: Text('Ok'),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                          }                                                           
                                                    
                                                          else
                                                          {
                                                            print("Running new board fct");
                                                            String pin = data['id'];
                                                            FirebaseDatabase.instance.reference().child('Customers/1234567890/Boards/$textValue/').set({
                                                              '$pin':'true'
                                                            });
                                                            textValue = "";
                                                            Navigator.of(context).pop();
                                                          }

                                                        }
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    }
                                },
                              );
                          }
                          else
                          {
                            return Container(width: 0.0, height: 0.0);
                            //print("SKIPPING?");
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
