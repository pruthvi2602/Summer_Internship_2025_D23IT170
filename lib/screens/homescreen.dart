import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tastybite/Utils/constants.dart';
import 'package:tastybite/screens/favorite_screen.dart';
import 'package:tastybite/screens/meal_plan_screen.dart';
import 'package:tastybite/screens/my_app_home_screen.dart';
import 'package:tastybite/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
    const MyAppHomeScreen(),
    const FavoriteScreen(),
     const MealPlanScreen(),    
      const SettingsScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 20,
          currentIndex: selectedIndex,
          selectedItemColor: testybiteprimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              TextStyle(color: testybiteprimaryColor, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 0 ? Iconsax.home5 : Iconsax.home1,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
              ),
              label: "Favorite",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
              ),
              label: "Meal Plan",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 3 ? Iconsax.setting_21 : Iconsax.setting,
              ),
              label: "Settings",
            )
          ],),
          body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(
      child: Icon(iconName, size: 100, color: Colors.lightBlue),
    );
  }
}
