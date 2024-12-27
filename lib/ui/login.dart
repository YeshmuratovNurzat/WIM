import 'dart:developer';
import 'package:WIM/domain/repo/LoginRepository.dart';
import 'package:WIM/ui/util/RoundButton.dart';
import 'package:WIM/ui/util/global.dart';
import 'package:WIM/ui/viewModel/LoginViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DbOpenHelper.dart';
import '../data/model/user_model.dart';
import '../data/network/Api.dart';
import 'home.dart';

void main() {
  final dio = Dio();
  final apiService = Api(dio);
  final loginRepository = LoginRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginRepository)),
      ],
      child: Login(),
    ),
  );
}

class Login extends StatelessWidget {
  const Login({super.key});

  static const platform = MethodChannel('com.example.android_id/android');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String androidId = "";
  String version = "";
  String firmaN = "";

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAndroidId();
    getVersion();
    getLogin();
    firmaName();
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
      padding: EdgeInsets.all(15),
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

  Widget buildLogin(LoginViewModel viewModel, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          fetchLogin(context, viewModel);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        child:
            Text('Войти', style: TextStyle(fontSize: 17, color: Colors.white)),
      ),
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
          "ID: $androidId",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          "v $version",
          style: TextStyle(fontSize: 15),
        )
      ],
    );
  }

  Future<void> fetchLogin(
      BuildContext context, LoginViewModel viewModel) async {
    final username = loginController.text.toString().replaceAll(' ', '');
    final password = passwordController.text.toString();

    saveLogin(username);

    final user = User(
      username: username,
      password: password,
      pdaId: androidId,
    );

    final login = await viewModel.login(user);

    if (login.error.isNotEmpty) {
      dialogShow(context, login.error.toString());
    }

    if (login.firmaName.isNotEmpty && login.id != "0") {
      buildDataBase(login.id, username, password, login.firmaName);
      navigatorHome();
    }
  }

  Future<void> buildDataBase(
      String id, String login, String password, String firmaName) async {
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
      setState(() {
        version = "Failed to get: '${e.message}'.";
      });
    }
  }

  Future<void> getAndroidId() async {
    try {
      final String result = await Login.platform.invokeMethod('getAndroidId');
      setState(() {
        androidId = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        androidId = "Failed to get ANDROID_ID: '${e.message}'.";
      });
    }
  }

  Future<void> firmaName() async {
    final db = await DbOpenHelper().database;
    final result = await db.rawQuery("select FirmaName from _users");
    firmaN = result.first['FirmaName'] as String;
    setState(() {});
    log("name $firmaN");
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Home()),
    );
  }
}
