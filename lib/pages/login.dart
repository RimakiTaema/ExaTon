import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// <-- your existing home page

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _tokenController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = _tokenController.text.trim();
    try {
        var url = Uri.https("api.exaroton.com", "v1/accounts");
        final response = await http.get(url, headers: {
            "Authorization": "Bearer $token",
          });
        print(response.body.toString());
      if (response.statusCode == 200) {
        // Save token securely
        await _storage.write(key: "api_token", value: token);

        // Call the callback to refresh auth state
        if (mounted && widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }
      } else {
        setState(() {
          _error = "Error ${response.statusCode}: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Login with Exaroton Token",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: "API Token",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}