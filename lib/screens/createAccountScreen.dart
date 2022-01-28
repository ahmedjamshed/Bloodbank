import 'package:bloodbank/blocs/register/register_bloc.dart';
import 'package:bloodbank/components/MyButton.dart';
import 'package:bloodbank/components/MyTextField.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateAccountScreen extends StatelessWidget {
  static String createAccountScreen = 'CreateAccount_Screen';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final FirebaseMessaging firebaseMessaging;
  const CreateAccountScreen({
    Key key,
    this.apiClient,
    this.chatApi,
    this.firebaseMessaging,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(
        apiClient: apiClient,
        chatApi: chatApi,
      ),
      child: CreateAccount(firebaseMessaging: firebaseMessaging),
    );
  }
}

class CreateAccount extends StatelessWidget {
  final FirebaseMessaging firebaseMessaging;
  CreateAccount({this.firebaseMessaging});
  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterState) {
          if (state.loading == true) {
            return SpinKitDoubleBounce(
              color: primaryColor,
              size: 20,
            );
          }
        } else if (state is RegisterFailure) {
        } else if (state is RegisterSuccess) {}
      },
      child: Scaffold(
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
                          'Create account',
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
                      FNameInput(editingComplete: () => node.nextFocus()),
                      LNameInput(editingComplete: () => node.nextFocus()),
                      EmailInput(editingComplete: () => node.nextFocus()),
                      PasswordInput(editingComplete: () => node.nextFocus()),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      CheckBox(),
                      SubmitButton(firebaseMessaging: firebaseMessaging),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FNameInput extends StatelessWidget {
  final Function editingComplete;
  FNameInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      // buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return MyTextField(
          limit: 20,
          defaultVal: state.name.value,
          label: "First Name",
          textInputType: TextInputType.name,
          icon: Icon(Icons.person),
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<RegisterBloc>()..add(NameChanged(name: val));
          },
        );
      },
    );
  }
}

class LNameInput extends StatelessWidget {
  final Function editingComplete;
  LNameInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.lName != current.lName,
      builder: (context, state) {
        return MyTextField(
          limit: 20,
          defaultVal: state.lName.value,
          label: "Last Name",
          textInputType: TextInputType.name,
          icon: Icon(Icons.person),
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<RegisterBloc>()..add(LNameChanged(lName: val));
          },
        );
      },
    );
  }
}

class EmailInput extends StatelessWidget {
  final Function editingComplete;
  EmailInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      // buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return MyTextField(
          limit: 30,
          defaultVal: state.email.value,
          label: "Email",
          textInputType: TextInputType.visiblePassword,
          icon: Icon(Icons.email),
          obsecure: false,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<RegisterBloc>()..add(EmailChanged(email: val));
          },
        );
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  final Function editingComplete;
  PasswordInput({this.editingComplete});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      // buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return MyTextField(
          limit: 20,
          defaultVal: state.password.value,
          label: "Password",
          icon: Icon(Icons.lock),
          textInputType: TextInputType.visiblePassword,
          obsecure: true,
          editingComplete: editingComplete,
          onChange: (val) {
            context.bloc<RegisterBloc>()..add(PasswordChanged(password: val));
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
    return BlocBuilder<RegisterBloc, RegisterState>(
      // buildWhen: (previous, current) => previous.check != current.check,
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
                  context.bloc<RegisterBloc>()..add(CheckChanged(check: flag));
                },
              ),
              SizedBox(
                width: width * 0.03,
              ),
              Text(
                "I agree to the Terms and Privacy Policy",
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
  final FirebaseMessaging firebaseMessaging;
  final ChatApiClient chatApi;
  SubmitButton({this.firebaseMessaging, this.chatApi});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      // buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return MyButton(
          title: "SIGNUP",
          onClick: () {
            context.bloc<RegisterBloc>()
              ..add(
                SignUpEvent(
                  context: context,
                  firebaseMessaging: firebaseMessaging,
                ),
              );
          },
        );
      },
    );
  }
}
