import 'dart:io';
import 'package:bloodbank/blocs/profile/profile_bloc.dart';
import 'package:bloodbank/components/MyButton.dart';
import 'package:bloodbank/constants/cloudinary.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/constants/styles.dart';
import 'package:bloodbank/constants/validators.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/models/user.dart';
import 'package:cloudinary_client/cloudinary_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shortid/shortid.dart';

class ProfileVerificationPage extends StatelessWidget {
  final User user;
  final ApiClient apiClient;

  ProfileVerificationPage({this.user, this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(apiClient: apiClient),
      child: ProfileVerification(
        user: user,
      ),
    );
  }
}

class ProfileVerification extends StatefulWidget {
  final User user;

  ProfileVerification({this.user});

  @override
  _ProfileVerificationState createState() => _ProfileVerificationState();
}

class _ProfileVerificationState extends State<ProfileVerification> {
  File cnic;
  File medical;
  String phone = "";
  bool loading = false;

  final picker = ImagePicker();
  CloudinaryClient client = new CloudinaryClient(apiKey, apiSecret, cloudName);

  Future getImage(String type, String clicked) async {
    try {
      if (type == "camera") {
        final pickedFile = await picker.getImage(source: ImageSource.camera);
        if (pickedFile != null) {
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

          if (clicked == "cnic") {
            setState(() {
              cnic = compressedFile;
            });
          } else {
            setState(() {
              medical = compressedFile;
            });
          }
        }
      } else {
        final pickedFile = await picker.getImage(source: ImageSource.gallery);
        if (pickedFile != null) {
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

          if (clicked == "cnic") {
            setState(() {
              cnic = compressedFile;
            });
          } else {
            setState(() {
              medical = compressedFile;
            });
          }
        }
      }
    } catch (_) {
      showToast(_.message);
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

  Future<void> _showMyDialog(String clicked) async {
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
                getImage("gallery", clicked);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Open Camera', style: TextStyle(color: primaryColor)),
              onPressed: () {
                getImage("camera", clicked);
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
    var width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 20, right: 20),
        child: ModalProgressHUD(
          inAsyncCall: loading,
          opacity: 0.1,
          color: secondaryColor,
          progressIndicator: SpinKitDoubleBounce(
            color: primaryColor,
            size: 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: pageColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
              ),
            ),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PageItem(
                    width: width,
                    onClick: () {
                      if (widget.user.phoneVerified) {
                        showToast("Your phone is already verified.");
                      } else if (phone == widget.user.phone ||
                          phone == "" ||
                          !Validators.isValidPhone(phone)) {
                        showToast("Invalid or Same phone number as before.");
                      } else {
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdatePhone(phone: phone),
                        );
                      }
                    },
                    onChange: (val) {
                      phone = val;
                    },
                    image: 'images/phoneIcon.png',
                    title: 'Phone Verification',
                    hint: 'Enter Phone',
                    defaultValue: widget.user.phone,
                    verified: widget.user.phoneVerified,
                    buttonTitle: 'Update Phone',
                  ),
                  SizedBox(
                    height: width * 0.06,
                  ),
                  Container(
                    height: 1,
                    color: greyDividerColor,
                  ),
                  PageItemTwo(
                    width: width,
                    onClick: () async {
                      if (widget.user.cnicVerified) {
                        showToast("Your CNIC is already verified.");
                      } else if (cnic != null) {
                        setState(() {
                          loading = true;
                        });
                        final response = await client.uploadImage(cnic.path);
                        print(response.url);
                        setState(() {});
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateCnic(cnic: response.url),
                        );
                        setState(() {
                          loading = false;
                          cnic = null;
                        });
                      } else {
                        showToast("Add/Replace image first.");
                      }
                    },
                    uploadClick: () {
                      _showMyDialog("cnic");
                    },
                    imageData: cnic != null ? cnic : widget.user.cnic,
                    image: 'images/idCardIcon.png',
                    title: 'CNIC Verification',
                    verifield: widget.user.cnicVerified,
                    buttonTitle: 'Update CNIC',
                  ),
                  SizedBox(
                    height: width * 0.06,
                  ),
                  Container(
                    height: 1,
                    color: greyDividerColor,
                  ),
                  PageItemTwo(
                    width: width,
                    onClick: () async {
                      if (widget.user.medicalVerified) {
                        showToast("Your medical report is already verified.");
                      } else if (medical != null) {
                        setState(() {
                          loading = true;
                        });
                        final response = await client.uploadImage(medical.path);
                        print(response.url);
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateMedical(medical: response.url),
                        );
                        setState(() {
                          loading = false;
                          medical = null;
                        });
                      } else {
                        showToast("Add/Replace image first.");
                      }
                    },
                    uploadClick: () {
                      _showMyDialog("medical");
                    },
                    imageData: medical != null ? medical : widget.user.medical,
                    image: 'images/reportIcon.png',
                    title: 'Medical Report Verification',
                    verifield: widget.user.medicalVerified,
                    buttonTitle: 'Update Report',
                  ),
                  SizedBox(
                    height: width * 0.06,
                  ),
                  Container(
                    height: 1,
                    color: greyDividerColor,
                  ),
                  SizedBox(
                    height: width * 0.06,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageItem extends StatelessWidget {
  const PageItem({
    Key key,
    @required this.width,
    @required this.onClick,
    @required this.title,
    @required this.buttonTitle,
    @required this.image,
    @required this.hint,
    this.defaultValue,
    this.verified,
    this.onChange,
  }) : super(key: key);

  final double width;
  final Function onClick;
  final String image;
  final String title;
  final String hint;
  final String buttonTitle;
  final String defaultValue;
  final bool verified;
  final Function onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                image,
                height: width * 0.1,
              ),
              SizedBox(
                width: width * 0.02,
              ),
              Text(
                title,
                style: TextStyle(
                  color: bg_color,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Open Sans",
                  fontSize: width * 0.04,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: width * 0.4,
                child: TextField(
                  maxLength: 11,
                  onChanged: onChange,
                  controller: TextEditingController(text: defaultValue),
                  cursorColor: bg_color,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Open Sans",
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 20),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: bg_color),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: bg_color),
                      ),
                      suffix: Text(
                        verified ? "Verified" : "UnVerified",
                        style: verified
                            ? kVerifiedTextStyle
                            : kUnVerifiedTextStyle,
                      ),
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: "Open Sans",
                        fontSize: 13,
                      )),
                ),
              ),
              MyButton(
                title: buttonTitle,
                onClick: onClick,
                myFontSize: 10,
                myPadding: 10,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PageItemTwo extends StatelessWidget {
  const PageItemTwo({
    Key key,
    @required this.width,
    @required this.onClick,
    @required this.title,
    @required this.buttonTitle,
    @required this.image,
    this.imageData,
    this.verifield,
    this.uploadClick,
  }) : super(key: key);

  final dynamic imageData;
  final double width;
  final Function onClick;
  final String image;
  final String title;
  final String buttonTitle;
  final bool verifield;
  final Function uploadClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                image,
                height: width * 0.1,
              ),
              SizedBox(
                width: width * 0.02,
              ),
              Text(
                title,
                style: TextStyle(
                  color: bg_color,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Open Sans",
                  fontSize: width * 0.04,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (imageData == "")
                          IconButton(
                            onPressed: uploadClick,
                            icon: Icon(
                              Icons.add_a_photo,
                              color: secondaryColor,
                            ),
                          ),
                        if (imageData != "" && imageData is File)
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: uploadClick,
                            child: Image.file(
                              imageData,
                              width: width * 0.17,
                              height: width * 0.13,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (imageData != "" && imageData is String)
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: uploadClick,
                            child: Image.network(
                              imageData,
                              width: width * 0.17,
                              height: width * 0.13,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(
                          width: width * 0.12,
                          child: Text(
                            verifield ? "Verified" : "UnVerified",
                            style: verifield
                                ? kVerifiedTextStyle
                                : kUnVerifiedTextStyle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: width * 0.4,
                      height: 1,
                      color: secondaryColor,
                    )
                  ],
                ),
              ),
              MyButton(
                title: buttonTitle,
                onClick: onClick,
                myFontSize: 10,
                myPadding: 10,
              )
            ],
          ),
        ],
      ),
    );
  }
}
