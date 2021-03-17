import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GMap extends StatefulWidget {
  GMap({Key key}) : super(key: key);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  bool mapToggle = false;
  var currentLocation;
  var businesses = [];

  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
        populateBusinesses();
      });
    });
  }

  populateBusinesses() {
    businesses = [];
    Firestore.instance.collection('Businesses').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; ++i) {
          businesses.add(docs.documents[i].data);
          initMarker(docs.documents[i].data);
        }
      }
    });
  }

  initMarker(business) {
    _markers.add(Marker(
        markerId: MarkerId("0"),
        position: LatLng(40.0376, -75.3592),
        infoWindow: InfoWindow(
          title: "Villanova",
          snippet: "School",
        )));
  }

  void _onMapCreated(GoogleMapController controller) {
    //this is to check if the map is ready to be used
    _mapController = controller;

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("0"),
          position: LatLng(40.0376, -75.3592),
          infoWindow: InfoWindow(
            title: "Villanova",
            snippet: "School",
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
                    height: MediaQuery.of(context).size.height - 80.0,
                    width: double.infinity,
                    child: mapToggle
                        ? GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(currentLocation.latitude,
                                  currentLocation.longitude),
                              zoom: 13,
                            ),
                            markers: _markers,
                            myLocationButtonEnabled: true,
                          )
                        : Center(
                            child: Text(
                            'Loading...',
                            style: TextStyle(fontSize: 20.0),
                          )))
              ],
            )
          ],
        ));
  }
}
