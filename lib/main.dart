import 'package:exaton/extra/AuthStorage.dart';
import 'package:exaton/pages/home.dart';
import 'package:exaton/pages/login.dart';
import 'package:flutter/material.dart';
// THIS BUILD IS NOT WORKING
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Exaton",
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _tokenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true) {
            return MainAppPage(onLogout: _refreshAuth);
          } else {
            return LoginPage(onLoginSuccess: _refreshAuth);
          }
        },
      ),
    );
  }

  void _refreshAuth() {
    setState(() {
      _tokenFuture = _checkToken();
    });
  }
}

class MainAppPage extends StatelessWidget {
  final VoidCallback onLogout;
  
  const MainAppPage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ExaTon',
          style: TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xffF7F8F8)
            ),
            child: Icon(Icons.dark_mode),
          )
        ],
      ),
      body: HomePage(),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.dashboard),
                      SizedBox(width: 10,),
                      Text(
                        'Servers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(width: 10,),
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 10,),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              color: Colors.grey[350],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Placeholder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            'Credits: ' 'Nill',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400
                            ),
                            textAlign: TextAlign.start,
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await AuthStorage.clear();
                          onLogout();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.logout
                          )
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
          ],
        )
      ),
    );
  }
}
