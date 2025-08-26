import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tastybite/Provider/favorite_provider.dart';
import 'package:tastybite/Utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites; // List of recipe IDs

    return Scaffold(
      backgroundColor: testybitebackgroundColor,
      appBar: AppBar(
        backgroundColor: testybitebackgroundColor,
        title: const Text(
          "Favorite",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                "No Favorite Items",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                String recipeId = favoriteItems[index];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('All_Foods_Recipe')
                      .doc(recipeId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Item not found in database"),
                      );
                    }

                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    final imageUrl = (data['image'] ?? '') as String;
                    final recipeName =
                        (data['name'] ?? 'Unnamed Recipe') as String;
                    final calories = (data['cal'] ?? '0').toString();
                    final time = (data['time'] ?? '0').toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            recipeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Iconsax.flash_1,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "$calories Cal",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Icon(Iconsax.clock,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "$time Min",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              provider.toggleFavorite(snapshot.data!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "$recipeName removed from favorites"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(
                              Iconsax.trash,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
