import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tastybite/Provider/favorite_provider.dart';
import 'package:tastybite/screens/homescreen.dart';
import 'package:tastybite/widgets/theme_provider.dart'; // <-- import themeNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider(_)),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier, // listen to changes
        builder: (context, mode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode, // <- important!
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
