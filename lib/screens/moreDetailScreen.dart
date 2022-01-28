import 'dart:io';
import 'package:bloodbank/blocs/profile/profile_bloc.dart';
import 'package:bloodbank/components/cityList.dart';
import 'package:bloodbank/constants/age.dart';
import 'package:bloodbank/constants/bloodGroups.dart';
import 'package:bloodbank/constants/cities.dart';
import 'package:bloodbank/constants/cloudinary.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bloodbank/components/MyButton.dart';
import 'package:bloodbank/components/MyTextField.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloudinary_client/cloudinary_client.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shortid/shortid.dart';

class MoreDetailScreen extends StatelessWidget {
  static String moreDetailScreen = 'MoreDetail_Screen';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final FirebaseMessaging firebaseMessaging;

  MoreDetailScreen({this.apiClient, this.chatApi, this.firebaseMessaging});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(apiClient: apiClient),
      child: MoreDetailWidget(
        apiClient: apiClient,
        chatApi: chatApi,
        firebaseMessaging: firebaseMessaging,
      ),
    );
  }
}

class MoreDetailWidget extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final FirebaseMessaging firebaseMessaging;

  MoreDetailWidget({this.apiClient, this.chatApi, this.firebaseMessaging});

  @override
  _MoreDetailWidgetState createState() => _MoreDetailWidgetState();
}

class _MoreDetailWidgetState extends State<MoreDetailWidget> {
  static List<String> _dropdownItems = ["male", "female"];
  CloudinaryClient client = new CloudinaryClient(apiKey, apiSecret, cloudName);
  String _dropdownValue;
  String ageValue;
  String cityValue;
  String reasonValue;
  String bloodType;
  dynamic profilePic = dummyImage;
  final picker = ImagePicker();
  bool loading = false;

  Future getImage(String type) async {
    try {
      if (type == "camera") {
        final pickedFile = await picker.getImage(source: ImageSource.camera);
        Directory dir = await getTemporaryDirectory();
        var targetPath = '';
        if (pickedFile.path.contains("jpg")) {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.jpg";
        } else if (pickedFile.path.contains("png")) {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.png";
        } else {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.jpeg";
        }

        File compressedFile =
            await compressAndGetFile(File(pickedFile.path), targetPath);
        setState(() {
          profilePic = compressedFile;
        });
      } else {
        final pickedFile = await picker.getImage(source: ImageSource.gallery);
        Directory dir = await getTemporaryDirectory();
        var targetPath = '';
        if (pickedFile.path.contains("jpg")) {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.jpg";
        } else if (pickedFile.path.contains("png")) {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.png";
        } else {
          var id = shortid.generate();
          targetPath = dir.absolute.path + "/$id.jpeg";
        }

        File compressedFile =
            await compressAndGetFile(File(pickedFile.path), targetPath);
        setState(() {
          profilePic = compressedFile;
        });
      }
    } catch (_) {
      print(_);
    }
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
      minWidth: 500,
      minHeight: 500,
    );
    return result;
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Upload Photo',
            style: TextStyle(color: primaryColor),
          ),
          content: Text(
            "Choose photo",
            style: TextStyle(color: primaryColor),
          ),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('From Gallery', style: TextStyle(color: primaryColor)),
              onPressed: () {
                getImage("gallery");
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Open Camera', style: TextStyle(color: primaryColor)),
              onPressed: () {
                getImage("camera");
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          return SpinKitDoubleBounce(
            color: primaryColor,
            size: 20,
          );
        } else if (state is ProfileFailure) {
        } else if (state is ProfileSuccess) {}
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              node.unfocus();
            },
            child: ModalProgressHUD(
              inAsyncCall: loading,
              opacity: 0.1,
              color: secondaryColor,
              progressIndicator: SpinKitDoubleBounce(
                color: primaryColor,
                size: 20,
              ),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('images/tellUsMore_bg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Text(
                          'Tell us more',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      if (profilePic is String)
                        CircleAvatar(
                          radius: 45.0,
                          backgroundColor: divider_color,
                          child: CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: () async {
                                await _showMyDialog();
                              },
                              icon: Icon(
                                Icons.add_a_photo,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      if (profilePic is File)
                        CircleAvatar(
                          radius: 45.0,
                          backgroundColor: divider_color,
                          child: CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.transparent,
                            backgroundImage: FileImage(profilePic),
                            child: FlatButton(
                              onPressed: () async {
                                await _showMyDialog();
                              },
                              child: null,
                            ),
                          ),
                        ),
                      PhoneInput(editingComplete: () => node.nextFocus()),
                      AddressInput(editingComplete: () => node.nextFocus()),
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
                      MyDropDownTextField(
                        label: "Gender",
                        dropdownValue: _dropdownValue,
                        dropDownItems: _dropdownItems,
                        onChange: (String newValue) {
                          setState(() {
                            _dropdownValue = newValue;
                          });
                        },
                      ),
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
                        label: "Blood Type",
                        dropdownValue: bloodType,
                        dropDownItems: bloodList,
                        onChange: (String newValue) {
                          setState(() {
                            bloodType = newValue;
                          });
                        },
                      ),
                      MyDropDownTextField(
                        label: "Reason",
                        dropdownValue: reasonValue,
                        dropDownItems: ["donor", "receiver"],
                        onChange: (String newValue) {
                          setState(() {
                            reasonValue = newValue;
                          });
                        },
                      ),
                      SubmitButton(
                        dropdownValue: _dropdownValue,
                        ageValue: ageValue,
                        cityValue: cityValue,
                        bloodType: bloodType,
                        reasonValue: reasonValue,
                        picture: profilePic,
                        client: client,
                        chatApi: widget.chatApi,
                        firebaseMessaging: widget.firebaseMessaging,
                        setLoading: () {
                          setState(() {
                            loading = !loading;
                          });
                        },
                      )
                    ],
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneInput extends StatelessWidget {
  final Function editingComplete;
  PhoneInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return MyTextField(
          limit: 11,
          defaultVal: state.phone.value,
          label: "Phone",
          textInputType: TextInputType.number,
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<ProfileBloc>().add(PhoneChanged(phone: val));
          },
        );
      },
    );
  }
}

class AddressInput extends StatelessWidget {
  final Function editingComplete;
  AddressInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.address != current.address,
      builder: (context, state) {
        return MyTextField(
          limit: 50,
          defaultVal: state.address.value,
          label: "Address",
          textInputType: TextInputType.streetAddress,
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<ProfileBloc>().add(AddressChanged(address: val));
          },
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String dropdownValue;
  final String ageValue;
  final String cityValue;
  final String bloodType;
  final String reasonValue;
  final dynamic picture;
  final CloudinaryClient client;
  final ChatApiClient chatApi;
  final FirebaseMessaging firebaseMessaging;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final Function setLoading;

  SubmitButton({
    this.dropdownValue,
    this.ageValue,
    this.cityValue,
    this.bloodType,
    this.reasonValue,
    this.picture,
    this.client,
    this.chatApi,
    this.firebaseMessaging,
    this.setLoading,
  });

  String checkValidation() {
    if (ageValue == null ||
        cityValue == null ||
        dropdownValue == null ||
        bloodType == null ||
        reasonValue == null) {
      return 'All fields are required.';
    } else
      return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return MyButton(
          title: "SIGNUP",
          onClick: () async {
            String check = checkValidation();
            if (check == '') {
              setLoading();
              var response;
              if (picture is File) {
                response = await client
                    .uploadImage(picture is String ? picture : picture.path);
                print(response.url);
              }
              final SharedPreferences prefs = await _prefs;
              final String oldBloodTopic = prefs.getString("blood_topic");
              final String oldPlasmaTopic = prefs.getString("plasma_topic");
              final String oldPlateletsTopic =
                  prefs.getString("platelets_topic");
              if (oldBloodTopic != null && oldBloodTopic != '') {
                _firebaseMessaging.unsubscribeFromTopic(oldBloodTopic);
              }
              if (oldPlasmaTopic != null && oldPlasmaTopic != '') {
                _firebaseMessaging.unsubscribeFromTopic(oldPlasmaTopic);
              }
              if (oldPlateletsTopic != null && oldPlateletsTopic != '') {
                _firebaseMessaging.unsubscribeFromTopic(oldPlateletsTopic);
              }

              final String bloodTopic = '${reasonValue}_${bloodType}_blood';
              final String plasmaTopic = '${reasonValue}_${bloodType}_plasma';
              final String plateletsTopic =
                  '${reasonValue}_${bloodType}_platelets';

              _firebaseMessaging.subscribeToTopic(bloodTopic);
              _firebaseMessaging.subscribeToTopic(plasmaTopic);
              _firebaseMessaging.subscribeToTopic(plateletsTopic);

              prefs.setString("blood_topic", bloodTopic);
              prefs.setString("plasma_topic", plasmaTopic);
              prefs.setString("platelets_topic", plateletsTopic);

              context.bloc<ProfileBloc>().add(UpdateProfile(
                    age: int.parse(ageValue),
                    city: cityValue,
                    gender: dropdownValue,
                    bloodType: bloodType,
                    reason: reasonValue,
                    context: context,
                    picture: response == null ? picture : response.url,
                    chatApi: chatApi,
                  ));
              setLoading();
            } else {
              showToast(check);
            }
          },
        );
      },
    );
  }
}
