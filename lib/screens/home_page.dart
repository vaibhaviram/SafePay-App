import 'package:flutter/material.dart';
import 'profile_widget.dart';
import 'wallet_page.dart';
import 'friends_page.dart';
import 'groups_page.dart';
import 'profile_page.dart';
import 'dashboard_page.dart';
import 'addnewitem_page.dart';
import 'notifications_page.dart';


class HomePage extends StatefulWidget {
  final String username;


  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;

  final List<Widget> screens = [
    DashboardPage(),
    AddNewItemPage(),
    FriendPage(),
    GroupPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: ProfileWidget(username: widget.username), // Profile icon navigates to ProfilePage
        title: const Text(
          'SafePay',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(),
                ),
              );
            },

            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              _handleMenuSelection(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Help"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text(""),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text("Option 3"),
              ),
            ],
          ),
        ],
      ),
      body: screens[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, int value) {
    switch (value) {
      case 1:
        print("Option 1 selected");
        break;
      case 2:
        print("Option 2 selected");
        break;
      case 3:
        print("Option 3 selected");
        break;
      default:
        break;
    }
  }
}
