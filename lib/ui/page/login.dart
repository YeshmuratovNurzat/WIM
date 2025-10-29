import 'dart:developer';
import 'package:WIM/ui/util/roundButton.dart';
import 'package:WIM/ui/util/global.dart';
import 'package:WIM/ui/viewModel/loginViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/dbOpenHelper.dart';
import '../../data/model/user_model.dart';
import 'home.dart';

class Login extends StatelessWidget {

  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }

}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  String version = "";
  String firmaN = "";
  String deviceId = "";

  static const platform = MethodChannel('com.example.app/device');

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDeviceId();
    getVersion();
    getLogin();
    // firmaName();
  }

  @override
  void dispose() {
    super.dispose();
    loginController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: true);

    return Scaffold(
        appBar: buildAppBar(),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00fffc95), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(child: buildContainer(loginViewModel, context))));
  }

  Widget buildContainer(LoginViewModel loginViewModel, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(firmaN, style: TextStyle(fontSize: 15)),
          SizedBox(height: 20),
          buildInput(),
          SizedBox(height: 25),
          buildLoginBtn(loginViewModel, context),
          SizedBox(height: 25),
          buildBottomText(),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text('WIM Service', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget buildInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: loginController,
          decoration: InputDecoration(
            labelText: 'Логин',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 15),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Пароль',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          obscureText: true,
        ),
      ],
    );
  }

  Widget buildLoginBtn(LoginViewModel viewModel, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: RoundButton(
          title: "Войти",
          loading: viewModel.isLoading,
          onPress: () {
            fetchLogin(context, viewModel);
          }),
    );
  }

  Widget buildBottomText() {
    return Column(
      children: [
        Text(
          "ID: $deviceId",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          "v $version",
          style: TextStyle(fontSize: 15),
        )
      ],
    );
  }

  Future<void> fetchLogin(BuildContext context, LoginViewModel viewModel) async {
    final login = loginController.text.toString().replaceAll(' ', '');
    final password = passwordController.text.toString();

    saveLogin(login);

    final user = User(
      login: login,
      password: password,
      pdaId: deviceId,
    );

    final result = await viewModel.login(user);

    if (result.error.isNotEmpty) {
      dialogShow(context, result.error.toString());
    }

    if (result.firmaName.isNotEmpty && result.id != "0") {
      buildDataBase(result.id, login, password, result.firmaName);
      navigatorHome();
    }

  }

  Future<void> buildDataBase(String id, String login, String password, String firmaName) async {
    final DbOpenHelper dbHelper = DbOpenHelper();
    await dbHelper.deleteAllUsers();
    await dbHelper.insertUser(int.parse(id), login, password, firmaName);

    Global().userId = id;
  }

  Future<void> getVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String result = packageInfo.version;
      setState(() {
        version = result;
      });
    } on PlatformException catch (e) {
      log("Ошибка: ${e.message}");
    }
  }

  Future<void> getDeviceId() async {
    try {
      final String result = await platform.invokeMethod('getDeviceId');
      setState(() {
        deviceId = result;
      });
    } on PlatformException catch (e) {
      log("Ошибка: ${e.message}");
    }
  }

  Future<void> firmaName() async {
    final db = await DbOpenHelper().database;
    final result = await db.rawQuery("select FirmaName from _users");
    setState(() {
      firmaN = result.first['FirmaName'] as String;
    });
  }

  Future<void> saveLogin(String login) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', login);
  }

  Future<void> getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginController.text = prefs.getString('login') ?? "";
    });
  }

  void dialogShow(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(text,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Закрыть',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigatorHome() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

}
