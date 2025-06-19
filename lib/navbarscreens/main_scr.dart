// import 'package:busapp/navbarscreens/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'home_screen.dart'; 
// import 'qr_screen.dart';   


// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();

//   final List<Widget> _screens = [
//     const HomeScreenMap(),
//     const QrscanScreen(),
//     const ProfileScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.jumpToPage(index); // Update PageView
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 15, 90, 95),
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.qr_code_scanner),
//             label: 'QR Scan',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
import 'package:busapp/navbarscreens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'qr_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0}); // Default to Home tab

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreenMap(),
    const QrscanScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 15, 90, 95),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
