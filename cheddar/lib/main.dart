import 'package:cheddar/user_provider.dart';
import 'package:cheddar/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme(
            primary: Colors.black87,
            onPrimary: Colors.white,
            secondary: Colors.black87,
            onSecondary: Colors.yellow,
            error: Colors.red,
            onError: Colors.black54,
            surface: const Color.fromARGB(255, 233, 236, 143),
            onSurface: Colors.black,
            
            brightness: Brightness.light,
          ),
          iconTheme: IconThemeData(color: Colors.black45),
          appBarTheme: const AppBarThemeData( 
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor:Color.fromARGB(221, 187, 176, 97), ),),

          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black87,
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.yellow,
            brightness: Brightness.dark,
          ),
          iconTheme: IconThemeData(color: Colors.white60),
          appBarTheme: const AppBarThemeData( 
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor:Colors.black87, ),),

          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black87,
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const WidgetTree(),
      ),
    );
  }
}
