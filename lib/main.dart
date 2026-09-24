import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pam_wealth_flow/firebase_options.dart';

import 'AppManager/view/account/login_view.dart';
import 'AppManager/view/account/language_view.dart';
import 'AppManager/view/dashboard/pam-wealth_dashboard.dart';
import 'AppManager/service/local_storage_service.dart';
import 'AppManager/service/deep_link_service.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool loggedIn = await LocalStorageService.isLoggedIn();
  final String? lang = await LocalStorageService.getLanguage();

  runApp(ProviderScope(
    child: PAMApp(
      isLoggedIn: loggedIn,
      language: lang,
    ),
  ));
}


class PAMApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? language;

  const PAMApp({
    super.key,
    required this.isLoggedIn,
    this.language,
  });

  @override
  State<PAMApp> createState() => _PAMAppState();
}

class _PAMAppState extends State<PAMApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Deep Links with a delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initDeepLinks(context, widget.language ?? 'en');
    });
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget initialHome;

    if (widget.isLoggedIn && widget.language != null) {
      initialHome = WealthCenterPage(language: widget.language!);
    } else if (widget.language != null) {
      initialHome = LoginPage(language: widget.language!);
    } else {
      initialHome = const LanguagePage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PAM Wealth Flow',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C12),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9B337),
          brightness: Brightness.dark,
        ),
      ),
      home: initialHome,
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
