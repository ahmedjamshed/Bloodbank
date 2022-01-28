import 'dart:math';
import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyDM3PbVBH_MmcTa0wDKN3nTk8M4NL6RfXg";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SearchScreen extends PlacesAutocompleteWidget {
  static String searchScreen = 'Search_Screen';
  SearchScreen()
      : super(
          apiKey: kGoogleApiKey,
          sessionToken: Uuid().generateV4(),
        );

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchScreenState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final appBar = AppBar(
      backgroundColor: secondaryColor,
      title: Container(
        height: width * 0.1,
        decoration: BoxDecoration(
            color: pageColor,
            borderRadius: BorderRadius.all(
              Radius.circular(width * 0.03),
            )),
        child: AppBarPlacesAutoCompleteTextField(
          textStyle: TextStyle(color: primaryColor),
          textDecoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: primaryColor),
              contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 14),
              border: InputBorder.none),
        ),
      ),
    );
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, searchScaffoldKey.currentState, context);
      },
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {}
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

Future<Null> displayPrediction(
    Prediction p, ScaffoldState scaffold, BuildContext context) async {
  if (p != null) {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    Map<String, dynamic> location = {
      'lat': lat,
      'lng': lng,
      'description': p.description
    };

    Navigator.of(context).pop(location);
  }
}
