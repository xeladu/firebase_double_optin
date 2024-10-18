import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_double_optin/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Double Opt-In',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Firebase Double Opt-In'),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 200,
              child: TextField(
                  decoration: const InputDecoration(
                      hintText: "Your email", border: OutlineInputBorder()),
                  onChanged: (value) => email = value)),
          const SizedBox(height: 10),
          SizedBox(
              width: 200,
              child: TextField(
                  decoration: const InputDecoration(
                      hintText: "Your password", border: OutlineInputBorder()),
                  onChanged: (value) => password = value)),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed:
                  FirebaseAuth.instance.currentUser == null ? _register : null,
              child: const Text("Create account")),
          if (FirebaseAuth.instance.currentUser != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                  "Account is ${FirebaseAuth.instance.currentUser!.emailVerified ? "verified" : "not verified"}"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: FirebaseAuth.instance.currentUser!.emailVerified
                    ? null
                    : _checkIfVerified,
                child: const Text("Check verification")),
          ]
        ])));
  }

  Future<void> _checkIfVerified() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();

      setState(() {});
    } catch (ex) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
                child: Text("The following error occured:\r\n$ex",
                    textAlign: TextAlign.center))));
      }
    }
  }

  Future<void> _register() async {
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await cred.user!.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Center(
                child: Text("Account created!\r\nCheck your inbox!",
                    textAlign: TextAlign.center))));
      }

      setState(() {});
    } catch (ex) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
                child: Text("The following error occured:\r\n$ex",
                    textAlign: TextAlign.center))));
      }
    }
  }
}
