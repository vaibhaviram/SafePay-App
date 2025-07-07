import 'package:flutter/material.dart';
import 'auth_page.dart'; // Import your AuthPage here

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _welcomeData = [
    {
      "image": "lib/assets/expense_tracking.png", // Add your image paths
      "title": "Track Expenses",
      "description": "Keep track of your daily expenses with ease.",
    },
    {
      "image": "lib/assets/split_bills.png",
      "title": "Split Bills",
      "description": "Easily split expenses among your friends and family.",
    },
    {
      "image": "lib/assets/secure_transactions.png",
      "title": "Secure Transactions",
      "description": "Your payments are safe and secure with us.",
    },
  ];

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50, // Soft purple background
      body: Column(
        children: [
          // PageView for Welcome Slides
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _welcomeData.length,
              itemBuilder: (context, index) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(
                      _welcomeData[index]["image"]!,
                      height: 250,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _welcomeData[index]["title"]!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      _welcomeData[index]["description"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dots for Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _welcomeData.length,
                  (index) => AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 5),
                height: 10,
                width: _currentPage == index ? 20 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          // Buttons for Navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    "Skip",
                    style: TextStyle(fontSize: 18, color: Colors.purple),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _welcomeData.length - 1) {
                      _onSkip();
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _currentPage == _welcomeData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
