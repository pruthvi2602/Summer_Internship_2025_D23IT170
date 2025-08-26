import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tastybite/Utils/constants.dart';
import 'package:tastybite/widgets/food_item_screen.dart';
import 'package:tastybite/widgets/my_icon_button.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeApp =
      FirebaseFirestore.instance.collection("All_Foods_Recipe");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testybitebackgroundColor,
      appBar: AppBar(
        backgroundColor: testybitebackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          Text(
            "Quick & Easy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          MyIconButton(icon: Iconsax.notification, pressed: () {}),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 5),
        child: Column(
          children: [
            SizedBox(height: 10,),
            StreamBuilder<QuerySnapshot>(
              stream: completeApp.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          snapshot.data!.docs[index];

                      return Column(
                        children: [
                          FoodItemScreen(documentSnapshot: documentSnapshot),
                          Row(
                            children: [
                              Icon(
                                Iconsax.star1,
                                color: Colors.amberAccent,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                documentSnapshot['rate'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("/5"),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "${documentSnapshot['reviews'.toString()]} Reviews",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
