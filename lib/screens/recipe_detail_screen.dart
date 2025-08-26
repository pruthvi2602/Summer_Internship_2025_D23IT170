import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int servings = 1; // default servings

  Future<void> _addToMealPlan(Map<String, dynamic> recipeData) async {
    // Day selector dialog
    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    String? selectedDay = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a Day"),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: days.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(days[index]),
                  onTap: () {
                    Navigator.pop(context, days[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedDay != null) {
      await FirebaseFirestore.instance.collection("meal_plan").add({
        "day": selectedDay,
        "name": recipeData["name"] ?? "Unnamed",
        "image": recipeData["image"] ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to $selectedDay meal plan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("All_Foods_Recipe")
            .doc(widget.recipeId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Recipe not found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          final imageUrl = data['image'] ?? '';
          final name = data['name'] ?? 'Unnamed Recipe';
          final calories = data['cal'] ?? '0';
          final time = data['time'] ?? '0';
          final rating = data['rate'] ?? '0';
          final reviews = data['reviews'] ?? '0';

          final ingredientNames =
              List<String>.from(data['ingridients_name'] ?? []);
          final ingredientAmounts =
              List<String>.from(data['ingridients_amount'] ?? []);
          final ingredientImages =
              List<String>.from(data['ingridients_image'] ?? []);

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Top Image =====
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 15,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ===== Recipe Info =====
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              )),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(Iconsax.flash_1,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("$calories Cal",
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 15),
                              Icon(Iconsax.clock, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("$time Min",
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 15),
                              const Icon(Iconsax.star1,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(rating,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(" ($reviews Reviews)",
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // ===== Ingredients Section =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ingredients",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // servings counter
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: () {
                                        if (servings > 1) {
                                          setState(() {
                                            servings--;
                                          });
                                        }
                                      },
                                    ),
                                    Text(servings.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          servings++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                          const Text("How many servings?",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),

                          const SizedBox(height: 15),

                          // ===== Ingredients List =====
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ingredientNames.length,
                            itemBuilder: (context, index) {
                              double baseAmount = 0;
                              try {
                                baseAmount = double.parse(
                                    ingredientAmounts[index]
                                        .replaceAll(RegExp(r'[^0-9.]'), ''));
                              } catch (e) {
                                baseAmount = 0;
                              }

                              double totalAmount = baseAmount * servings;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        ingredientImages[index],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        ingredientNames[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${totalAmount.toStringAsFixed(1)} gm",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Bottom Buttons Fixed =====
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    // Start Cooking Button (Expanded)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Start Cooking Action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Start Cooking",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add to Meal Button (Round)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons
                              .restaurant_menu, // you can change to Iconsax.add or any meal icon
                          color: Colors.teal,
                          size: 28,
                        ),
                        onPressed: () => _addToMealPlan(data),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
