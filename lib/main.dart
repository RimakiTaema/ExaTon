import 'package:exaton/exaroton/src/apis/accounts.dart';
import 'package:exaton/extra/AuthStorage.dart';
import 'package:exaton/pages/home.dart';
import 'package:exaton/pages/login.dart';
import 'package:flutter/material.dart';

Future<double?> fetchCredits() async {
  final token = await AuthStorage.getToken();
  if (token == null || token.isEmpty) return null;
  final response = await GetAccount(token: token).run();
  return response.data?.credits;
}

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
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _checkToken();
  }

  Future<bool> _checkToken() async {
  try {
    final token = await AuthStorage.getToken();
    return token != null && token.isNotEmpty;
    } catch (e) {
    print('❌ Token check failed: $e');
    return false;
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthStorage.clear();
    setState(() {
      _tokenFuture = _checkToken();
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onLoginSuccess: _refreshAuth),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Exaton",
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
      ),
      themeMode: _themeMode,
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
            return MainAppPage(
              onLogout: () {
                _logout(context);
              },
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
            );
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
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  
  const MainAppPage({
    super.key,
    required this.onLogout,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
        backgroundColor: scheme.surface,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          ),
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
                          FutureBuilder<String?>(
                            future: AuthStorage.getUsername(),
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? 'Placeholder';
                              return Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.start,
                              );
                            },
                          ),
                          FutureBuilder<double?>(
                            future: fetchCredits(),
                            builder: (context, snapshot) {
                              final credits = snapshot.data;
                              final text = credits != null
                                  ? 'Credits: $credits'
                                  : 'Credits: Nill';
                              return Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.start,
                              );
                            },
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onLogout,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.logout,
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
