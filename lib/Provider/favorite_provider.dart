import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favorieIds = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favorites => _favorieIds;

  FavoriteProvider(BuildContext context) {
    loadFavorites();
  }

  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favorieIds.contains(productId)) {
      _favorieIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favorieIds.add(productId);
      await _addFavorite(productId);
    }
    notifyListeners();
  }

  bool isExist(DocumentSnapshot product) {
    return _favorieIds.contains(product.id);
  }

  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite':
            true, // create the userafavorite collection and add item as favorites inf firestore
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Remove favorite form firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  //load favorite from firestore (store favorite or not)
  Future<void> loadFavorites() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection("userFavorite").get();
      _favorieIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
