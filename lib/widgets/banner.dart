import 'package:flutter/material.dart';
import 'package:tastybite/Utils/constants.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: testybiteBannerColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Cook the best\nrecipes at home",
                  style: TextStyle(
                    height: 1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 33,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Explore",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.asset(
              "assets/images/Chef.png"),
          ),
        ],
      ),
    );
  }
}
