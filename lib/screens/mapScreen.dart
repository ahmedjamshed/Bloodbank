import 'dart:async';

import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/screens/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  static String mapScreen = 'Maps_screen';

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  Completer<GoogleMapController> _controller = Completer();
  String address = "Locating...";
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 0,
  );
  CameraPosition myPosition;
  Coordinates myCoordinates;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    List<Address> tempAddress =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.4746,
      );
      address = tempAddress[0].addressLine;
      myCoordinates = coordinates;
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }

  void _updateAddress() async {
    final coordinates = new Coordinates(
        myPosition.target.latitude, myPosition.target.longitude);
    List<Address> tempAddress =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      address = tempAddress[0].addressLine;
      myCoordinates = coordinates;
    });
  }

  void _updateFromSearch(response) async {
    final coordinates = new Coordinates(response['lat'], response['lng']);
    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(response['lat'], response['lng']),
        zoom: 15.4746,
      );
      address = response['description'];
      myCoordinates = coordinates;
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg_color,
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.searchScreen)
                  .then((response) {
                if (response != "") {
                  _updateFromSearch(response);
                }
              });
            },
            icon: Icon(Icons.search),
          )
        ],
        title: Text(
          "Choose Location",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Open Sans",
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: pageColor,
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: height * 0.78,
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onCameraMove: (_position) {
                        setState(() {
                          myPosition = _position;
                        });
                      },
                      onCameraIdle: _updateAddress,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    Center(
                      child: Icon(
                        Icons.location_on,
                        color: bg_color,
                        size: width * 0.15,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height * 0.12,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(top: width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: width * 0.01,
                          ),
                          SizedBox(
                            width: width * 0.65,
                            child: Text(
                              address,
                              maxLines: 3,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop(myCoordinates);
                            },
                            elevation: 2.0,
                            height: width * 0.15,
                            color: bg_color,
                            child: Icon(
                              Icons.check,
                              size: 35.0,
                              color: Colors.white,
                            ),
                            //padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
