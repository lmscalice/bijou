import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bijou/gmap.dart';
import 'package:bijou/nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bijou',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home:
          Nav(), //so i guess, when we implemenet discover, this will be Discover() which will have Nav()
    );
  }
}
