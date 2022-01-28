import 'package:bloodbank/graphql/chat/client.dart';
import 'package:bloodbank/graphql/client.dart';
import 'package:bloodbank/screens/contactsTab.dart';
import 'package:bloodbank/screens/homeTab.dart';
import 'package:bloodbank/screens/chatList_screen.dart';
import 'package:bloodbank/screens/notificationsTab.dart';
import 'package:bloodbank/screens/settingsTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabNavigator extends StatefulWidget {
  static String tabNavigator = 'Tab_Navigator';
  final ApiClient apiClient;
  final ChatApiClient chatApi;
  final String yourId;

  TabNavigator({this.apiClient, this.chatApi, this.yourId});

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  Widget widgetOptions(
    ApiClient apiClient,
    ChatApiClient chatApi,
    String yourId,
    int index,
  ) {
    if (index == 0) {
      return ContactsTab(
        apiClient: apiClient,
        chatApi: chatApi,
        myId: yourId,
      );
    }
    if (index == 1) {
      return ChatListScreen(
        apiClient: widget.apiClient,
        chatApi: widget.chatApi,
        yourId: yourId,
      );
    }
    if (index == 2) {
      return HomeTab(
        apiClient: apiClient,
        chatApi: chatApi,
        yourId: yourId,
      );
    }
    if (index == 3) {
      return NotificationsTab(
        apiClient: apiClient,
        chatApi: chatApi,
      );
    }
    return SettingsTab(
      apiClient: apiClient,
      chatApi: chatApi,
      yourId: yourId,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: widgetOptions(
            widget.apiClient,
            widget.chatApi,
            widget.yourId,
            _selectedIndex,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              label: "Contacts",
              icon: Image.asset(
                _selectedIndex == 0
                    ? 'images/contacts_selected.png'
                    : 'images/contacts.png',
                width: _selectedIndex == 0 ? width * 0.09 : width * 0.07,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              label: "Chats",
              icon: Image.asset(
                _selectedIndex == 1
                    ? 'images/messages_selected.png'
                    : 'images/messages.png',
                height: _selectedIndex == 1 ? width * 0.085 : width * 0.07,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              label: "Home",
              icon: Image.asset(
                _selectedIndex == 2
                    ? 'images/home_selected.png'
                    : 'images/home.png',
                height: _selectedIndex == 2 ? width * 0.085 : width * 0.07,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              label: "Notifications",
              icon: Image.asset(
                _selectedIndex == 3
                    ? 'images/notification_selected.png'
                    : 'images/notifications.png',
                height: _selectedIndex == 3 ? width * 0.085 : width * 0.07,
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              label: "Settings",
              icon: Image.asset(
                _selectedIndex == 4
                    ? 'images/settings_selected.png'
                    : 'images/settings.png',
                height: _selectedIndex == 4 ? width * 0.085 : width * 0.07,
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
        ),
      ),
    );
  }
}
