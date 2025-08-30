import 'package:WIM/ui/page/login.dart';
import 'package:WIM/ui/viewModel/loginViewModel.dart';
import 'package:WIM/ui/viewModel/settingViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'data/network/api.dart';
import 'domain/loginRepository.dart';
import 'domain/settingRepository.dart';

void main() {
  final dio = Dio();
  final apiService = Api(dio);
  final settingRepository = SettingRepository(apiService);
  final loginRepository = LoginRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingViewModel(settingRepository)),
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginRepository)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', ''), // Русская локализация
        const Locale('en', ''), // Английская локализация
      ],
      locale: const Locale('ru'),
      debugShowMaterialGrid: false,
      home: const LoginPage(),
    );
  }
}