import 'package:bloodbank/blocs/login/login_bloc.dart';
import 'package:bloodbank/components/MyButton.dart';
import 'package:bloodbank/components/MyTextField.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/createAccountScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../constants/validators.dart';

class LoginScreen extends StatelessWidget {
  static String loginScreen = 'Login_Screen';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final FirebaseMessaging firebaseMessaging;
  const LoginScreen({
    Key key,
    this.apiClient,
    this.chatApi,
    this.yourId,
    this.firebaseMessaging,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(apiClient: apiClient),
      child: Login(
        apiClient: apiClient,
        chatApi: chatApi,
        yourId: yourId,
        firebaseMessaging: firebaseMessaging,
      ),
    );
  }
}

class Login extends StatefulWidget {
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;
  final FirebaseMessaging firebaseMessaging;

  Login({
    this.apiClient,
    this.chatApi,
    this.yourId,
    this.firebaseMessaging,
  });
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkBoxFlag = false;
  String email = "";
  String password = "";

  String checkValidation(String email, String password) {
    if (email == '' || password == '') {
      return 'All fields are required.';
    }
    if (!Validators.isValidEmail(email)) {
      print('Email is not valid.');
      return 'Email is not valid.';
    }
    if (!Validators.isValidPassword(password)) {
      return 'Password should contain at least 8 characters with minimum one digit.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            node.unfocus();
          },
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('images/createAccount_bg.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    MyTextField(
                      limit: 30,
                      label: "Email",
                      textInputType: TextInputType.emailAddress,
                      defaultVal: email,
                      icon: Icon(Icons.email),
                      obsecure: false,
                      editingComplete: () => node.nextFocus(),
                      onChange: (val) {
                        email = val;
                      },
                    ),
                    MyTextField(
                      limit: 20,
                      label: "Password",
                      textInputType: TextInputType.visiblePassword,
                      defaultVal: password,
                      obsecure: true,
                      icon: Icon(Icons.lock),
                      onChange: (val) {
                        password = val;
                      },
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    MyButton(
                      title: "LOGIN",
                      onClick: () {
                        String check = checkValidation(email, password);
                        if (check == '') {
                          BlocProvider.of<LoginBloc>(context).add(
                            LogEvent(
                              email: email,
                              password: password,
                              context: context,
                              chatApi: widget.chatApi,
                              yourId: widget.yourId,
                            ),
                          );
                        } else {
                          showToast(check);
                        }
                      },
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.1),
                          child: Text('Don\'t have an account?'),
                        ),
                        FlatButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: RouteSettings(
                                name: CreateAccountScreen.createAccountScreen,
                              ),
                              builder: (context) => CreateAccountScreen(
                                apiClient: widget.apiClient,
                                chatApi: widget.chatApi,
                                firebaseMessaging: widget.firebaseMessaging,
                              ),
                            ),
                          ),
                          child: Text(
                            'Signup',
                            style: TextStyle(color: secondaryColor),
                          ),
                        )
                      ],
                    ),
                    BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                      if (state is LoginLoading) {
                        return SpinKitDoubleBounce(
                          color: primaryColor,
                          size: 20,
                        );
                      } else if (state is LoginFailure) {
                      } else if (state is LoginSuccess) {}
                      return Container(
                        height: 0,
                        width: 0,
                      );
                    })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
