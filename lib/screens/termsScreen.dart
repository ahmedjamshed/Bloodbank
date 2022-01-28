import 'package:bloodbank/components/app_bar.dart';
import 'package:bloodbank/constants/colors.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  static String termsScreen = 'Terms_Screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(
        context: context,
        title: 'Terms and Policies',
        action: '',
        backIcon: true,
      ),
      backgroundColor: containerColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: RichText(
              text: TextSpan(
                text:
                    "The Blood Bank App is created by Appsace. It is a free downloadable app and intended to be used as it is. The following Privacy Policy is for the users referred to as “the client” and is independent of the Privacy Policy clauses mentioned on the website. The personal information of the client is referred to as “the data” in this document.\n\nThe app is available for free download from Google Play Store on Apple App Store and is kept up to date.",
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: "\n\n1. Data Collection:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "\nTo deliver a smooth experience, this app collects the following data of the clients:\n",
                  ),
                  TextSpan(
                    text:
                        "\n\t•	Name of the client\n\t•	Contact information\n\t•	Email address\n\t•	Medical history\n",
                  ),
                  TextSpan(
                    text:
                        "\nThe clients are advised to give all the information as accurately as possible for medical purposes.\n\nAny compromise occurring due to misinformation on the client's part cannot be reflected as negligence on the part of the app. The Blood Bank App is obliged to start a legal proceeding to protect their interests.The app uses all the data to ensure the best donor matches and does not, in any case, use the data for commercial or financial gains.\n",
                  ),
                  TextSpan(
                    text:
                        "\nIf at any point, the client feels that he/she needs to change the data, they can do so by updating their personal information through the app.\n\nThe app sends out an email regarding these changes; it’s in the client's interest to read those emails and take necessary actions.",
                  ),
                  TextSpan(
                    text: "\n\n2. Security:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "\nThe protection of our client’s data is our utmost priority. Please read the following clauses to better understand the security of the data.\n",
                  ),
                  TextSpan(
                    text:
                        "\n\t•	All the client data is stored on our servers, regularly maintained and secured by top of the line security firms and software.\n\n\t•	Any breach on the app’s part regarding the data will be properly justified to the client, and Blood Bank App will fairly compensate the aggrieved party against all the damages suffered.\n\n\t•	Similarly, if the app's security is compromised on behalf of the client's faulty data, Blood Bank App might ask for compensation or start a legal process against such clients.\n\n\t•	The app serves a medical purpose, so to avoid any untoward scenario, all the data must be accurate and up to date.",
                  ),
                  TextSpan(
                    text: "\n\n3. App Updates:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "\nTo maintain the security of our client’s data, the app is regularly updated. The client must always look for new updates on the store and keep the app updated.\n\nBecause of using previous versions of the app, any data loss suffered by the client cannot be held against the app creators or the Blood Bank App.\n\nThe servers often undergo maintenance to better protect the client data; during those times, if the app is unresponsive, logs out the client, or deletes the account, rest assured that all the data will be secure under any circumstances.\n",
                  ),
                  TextSpan(
                    text:
                        "\nIf a scenario where one of the issues mentioned above does occur, the client is advised to either re-install the app, log in with their old account, or register a new account.\n\nIf the client suffers any damages due to these issues, it will not be held against the app or Blood Bank App.",
                  ),
                  TextSpan(
                    text: "\n\n4. Account Termination:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "\nPlease read the following clauses regarding the termination of the account:\n",
                  ),
                  TextSpan(
                    text:
                        "\nThe app is intended to be used by people of age 18 years and above; if by any chance an underage user is detected, the account will be terminated without any prior notification.\n\nThe app is subjected to a fair usage policy; if the client is found breaching regarding fair usage, his/her account might be permanently terminated.\n",
                  ),
                  TextSpan(
                    text:
                        "\nThe Blood Bank App is a property of Appsace and serves to offer assistance to its client; third party owners are not encouraged. The clients should also use the app for their personal use, if found otherwise, the account will be terminated, and legal action might be taken.\n",
                  ),
                  TextSpan(
                    text:
                        "\nThis app, as mentioned before, serves a medical purpose and is free to download and use. The same goes for the clients; if found guilty of using the app for financial purposes, their accounts will be permanently banned, and legal action will be taken as applicable by the law.",
                  ),
                  TextSpan(
                    text: "\n\n5. Privacy Policy Changes:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "\nDue to the purpose of this app, “privacy policies” are regularly updated. The clients are advised to read and review the Privacy Policy once a month.\n\nIf a loss of data or account occurs due to the client's ignorance regarding changes in the privacy policy, it will not be held against the Blood Bank App or the creators.\n\nThese changes do not affect the app or its content. However, in case of such occurrence, the clients are advised to contact via email and relay their concerns to ensure a smooth experience.",
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
