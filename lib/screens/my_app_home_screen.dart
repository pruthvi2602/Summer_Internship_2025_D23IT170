import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tastybite/Utils/constants.dart';
import 'package:tastybite/screens/view_all_items.dart';
import 'package:tastybite/widgets/banner.dart';
import 'package:tastybite/widgets/food_item_screen.dart';
import 'package:tastybite/widgets/my_icon_button.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";

  // Firestore collections
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App_Category");

  Query get filteredRecipes => FirebaseFirestore.instance
      .collection("All_Foods_Recipe")
      .where('category', isEqualTo: category);

  Query get allRecipes =>
      FirebaseFirestore.instance.collection("All_Foods_Recipe");

  Query get selectedRecipes => category == "All" ? allRecipes : filteredRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testybitebackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              mySearchBar(),
              const BannerToExplore(),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              selectedCategory(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quick & Easy",
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewAllItems(),
                        ),
                      );
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: testybiteBannerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              recipeList(), // ✅ Shows filtered recipe cards
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Recipe card list
  Widget recipeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedRecipes.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> recipes = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(top: 5, left: 15),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recipes
                  .map((doc) => FoodItemScreen(documentSnapshot: doc))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Category chips
  Widget selectedCategory() {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesItems.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(top: 5, left: 15),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(docs.length, (index) {
                final name = docs[index]["name"];
                final isSelected = category == name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      category = name;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: isSelected ? testybiteprimaryColor : Colors.white,
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Search bar with header
  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const Header(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                prefixIcon: const Icon(Iconsax.search_normal),
                fillColor: Colors.white,
                border: InputBorder.none,
                hintText: "Search any recipes",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.notification,
          pressed: () {},
        ),
      ],
    );
  }
}
