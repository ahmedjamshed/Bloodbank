import 'package:bloodbank/blocs/posts/posts_bloc.dart';
import 'package:bloodbank/components/MyTextField.dart';
import 'package:bloodbank/components/MyTextFieldButton.dart';
import 'package:bloodbank/components/cityList.dart';
import 'package:bloodbank/constants/age.dart';
import 'package:bloodbank/constants/bloodGroups.dart';
import 'package:bloodbank/constants/bloodTypes.dart';
import 'package:bloodbank/constants/cities.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/mapScreen.dart';
import 'package:bloodbank/screens/tabNavigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:geocoder/geocoder.dart';

class ShoutOutScreen extends StatelessWidget {
  static String shoutOutScreen = 'ShoutOut_Screen';
  const ShoutOutScreen({Key key, this.userID, this.apiClient, this.userType})
      : super(key: key);
  final String userID;
  final ApiClient apiClient;
  final String userType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostsBloc(apiClient: apiClient),
      child: ShoutOut(userID: userID, apiClient: apiClient, userType: userType),
    );
  }
}

class ShoutOut extends StatefulWidget {
  final String userID;
  final ApiClient apiClient;
  final String userType;
  ShoutOut({this.userID, this.apiClient, this.userType});

  @override
  _ShoutOutState createState() => _ShoutOutState();
}

class _ShoutOutState extends State<ShoutOut> {
  String cityValue;
  String ageValue;
  String bloodValue;
  String bloodType;
  String addressVal = "Pick Location";
  String hospValue = "Pick Location";
  double addressLat;
  double addressLon;
  double hospLat;
  double hospLon;

  updateAddress(Coordinates coordinates) async {
    List<Address> tempAddress =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      addressVal = tempAddress[0].addressLine;
      addressLat = coordinates.latitude;
      addressLon = coordinates.longitude;
    });
  }

  updateHospAddress(Coordinates coordinates) async {
    List<Address> tempAddress =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      hospValue = tempAddress[0].addressLine;
      hospLat = coordinates.latitude;
      hospLon = coordinates.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return Scaffold(
        backgroundColor: pageColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bg_color,
          automaticallyImplyLeading: false,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: RouteSettings(name: TabNavigator.tabNavigator),
                  builder: (context) => TabNavigator(
                    apiClient: widget.apiClient,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(
            "Shoutout For Blood",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Open Sans",
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: BlocListener<PostsBloc, PostsState>(
          listener: (context, state) {
            if (state is PostsLoading) {
              return SpinKitDoubleBounce(
                color: primaryColor,
                size: 20,
              );
            } else if (state is PostsFailure) {
              showToast("  ${state.message}  ");
            } else if (state is PostsSuccess) {
              showToast("  Post Created Successfully!  ");
            }
          },
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                node.unfocus();
              },
              child: Container(
                color: pageColor,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.06),
                          child: Text(
                            "Patient Details",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: width * 0.06, top: width * 0.04),
                          child: Text(
                            "* You are a ${widget.userType} right now, if you are creating this shoutout to ${widget.userType == "donor" ? "receive" : "donate"} blood. Go to settings tab and change your profile settings.",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                        NameInput(editingComplete: () => node.nextFocus()),
                        DiseaseInput(editingComplete: () => node.nextFocus()),
                        MyDropDownTextField(
                          label: "Age",
                          dropdownValue: ageValue,
                          dropDownItems: ageList,
                          onChange: (String newValue) {
                            setState(() {
                              ageValue = newValue;
                            });
                          },
                        ),
                        MyDropDownTextField(
                          label: "Blood Group",
                          dropdownValue: bloodValue,
                          dropDownItems: bloodList,
                          onChange: (String newValue) {
                            setState(() {
                              bloodValue = newValue;
                            });
                          },
                        ),
                        MyDropDownTextField(
                          label: "Blood Type Required",
                          dropdownValue: bloodType,
                          dropDownItems: bloodTypes,
                          onChange: (String newValue) {
                            setState(() {
                              bloodType = newValue;
                            });
                          },
                        ),
                        MyTextFieldButton(
                          label: "Address",
                          dropdownValue: addressVal,
                          onClick: () {
                            Navigator.pushNamed(context, MapsScreen.mapScreen)
                                .then((value) {
                              if (value != null) {
                                updateAddress(value);
                              }
                            });
                          },
                        ),
                        MyTextFieldButton(
                          label: "Hospital Address",
                          dropdownValue: hospValue,
                          onClick: () {
                            Navigator.pushNamed(context, MapsScreen.mapScreen)
                                .then((value) {
                              if (value != null) {
                                updateHospAddress(value);
                              }
                            });
                          },
                        ),
                        MyDropDownTextField(
                          label: "City",
                          dropdownValue: cityValue,
                          dropDownItems: citiesList,
                          onChange: (String newValue) {
                            setState(() {
                              cityValue = newValue;
                            });
                          },
                        ),
                        CheckBox(),
                        SubmitButton(
                          userID: widget.userID,
                          cityValue: cityValue,
                          ageValue: ageValue,
                          bloodValue: bloodValue,
                          bloodType: bloodType,
                          addressLat: addressLat,
                          addressLon: addressLon,
                          hospLat: hospLat,
                          hospLon: hospLon,
                          context: context,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class NameInput extends StatelessWidget {
  final Function editingComplete;
  NameInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return MyTextField(
          limit: 20,
          defaultVal: state.name.value,
          label: "Name",
          textInputType: TextInputType.name,
          obsecure: false,
          onChange: (val) {
            context.bloc<PostsBloc>().add(NameChanged(name: val));
          },
          editingComplete: editingComplete,
        );
      },
    );
  }
}

class DiseaseInput extends StatelessWidget {
  final Function editingComplete;
  DiseaseInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(
      buildWhen: (previous, current) => previous.disease != current.disease,
      builder: (context, state) {
        return MyTextField(
          limit: 20,
          defaultVal: state.disease.value,
          label: "Disease",
          textInputType: TextInputType.name,
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<PostsBloc>().add(DiseaseChanged(disease: val));
          },
        );
      },
    );
  }
}

class CheckBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BlocBuilder<PostsBloc, PostsState>(
      buildWhen: (previous, current) => previous.check != current.check,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: state.check,
                activeColor: primaryColor,
                onChanged: (flag) {
                  context.bloc<PostsBloc>().add(CheckChanged(check: flag));
                },
              ),
              SizedBox(
                width: width * 0.03,
              ),
              Text(
                "I agree entered details are correct",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String userID;
  final String cityValue;
  final String ageValue;
  final String bloodValue;
  final String bloodType;
  final double addressLat;
  final double addressLon;
  final double hospLat;
  final double hospLon;
  final BuildContext context;

  SubmitButton({
    this.userID,
    this.cityValue,
    this.ageValue,
    this.bloodValue,
    this.bloodType,
    this.addressLat,
    this.addressLon,
    this.hospLat,
    this.hospLon,
    this.context,
  });

  String checkValidation() {
    if (cityValue == null ||
        ageValue == null ||
        bloodValue == null ||
        bloodType == null ||
        addressLat == null ||
        addressLon == null ||
        hospLat == null ||
        hospLon == null) {
      return 'All fields are required.';
    } else
      return '';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BlocBuilder<PostsBloc, PostsState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.07,
            vertical: width * 0.02,
          ),
          child: RaisedButton(
            padding: EdgeInsets.symmetric(
              vertical: width * 0.04,
              horizontal: 20,
            ),
            onPressed: () {
              String check = checkValidation();
              if (check == '') {
                context.bloc<PostsBloc>().add(
                      CreatePost(
                        userId: userID,
                        age: int.parse(ageValue),
                        city: cityValue,
                        bloodType: bloodType,
                        bloodValue: bloodValue,
                        addressLat: addressLat,
                        addressLon: addressLon,
                        hospLat: hospLat,
                        hospLon: hospLon,
                        context: context,
                      ),
                    );
              } else {
                showToast(check);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: primaryColor,
            child: Text(
              'Send Shoutout',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
