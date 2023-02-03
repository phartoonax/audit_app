import 'package:audit_app/screeens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

FocusNode node = new FocusNode();

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  String? onerror;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 0.85.sh,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 90,
                ),
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "email tidak bisa kosong";
                                  } else {
                                    value = value.trim();
                                    return null;
                                  }
                                },
                                focusNode: node,
                                maxLines: 1,
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  errorText: onerror,
                                  prefixIcon: const Icon(Icons.people),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              PasswordInput(
                                  hintText: "Enter your password",
                                  textEditingController: passwordController,
                                  onerror: onerror),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (_formKey.currentState!.validate()) {
                              Backendless.userService
                                  .login(emailController.text,
                                      passwordController.text, true)
                                  .then((user) {
                                Backendless.userService
                                    .isValidLogin()
                                    .then((response) {
                                  print("Is login valid? - $response");
                                  if (response == true && user != null) {
                                    final sbarnoticeabsen = SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 4),
                                      content: Text("Login Berhasi!"),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(sbarnoticeabsen);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                                userdata: user,
                                              )),
                                    );
                                  }
                                }).catchError((onError, stackTrace) {
                                  print(
                                      "There has been an error inside: $onError");
                                  PlatformException platformException = onError;
                                  print("Server reported an error inside.");
                                  print(
                                      "Exception code: ${platformException.code}");
                                  print(
                                      "Exception details: ${platformException.details}");
                                  print("Stacktrace: $stackTrace");
                                }, test: (e) => e is PlatformException);
                              }).catchError((onError, stackTrace) {
                                print(
                                    "There has been an error outside: $onError");
                                PlatformException platformException = onError;
                                print("Server reported an error outside.");
                                print(
                                    "Exception code: ${platformException.code}");
                                print(
                                    "Exception details: ${platformException.details}");
                                print("Stacktrace: $stackTrace");
                                onerror = platformException.details;
                                final sbarnoticeabsen = SnackBar(
                                  duration: Duration(seconds: 10),
                                  content: Text(
                                      "telah terjadi sebuah error. ${platformException.details}"),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () =>
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar(),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(sbarnoticeabsen);
                              }, test: (e) => e is PlatformException);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final String? onerror;

  const PasswordInput(
      {required this.textEditingController,
      required this.hintText,
      Key? key,
      this.onerror})
      : super(key: key);

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool pwdVisibility = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      obscureText: !pwdVisibility,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: widget.hintText,
        errorText: widget.onerror,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: InkWell(
          onTap: () => setState(
            () => pwdVisibility = !pwdVisibility,
          ),
          child: Icon(
            pwdVisibility
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade400,
            size: 18,
          ),
        ),
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return 'password tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
