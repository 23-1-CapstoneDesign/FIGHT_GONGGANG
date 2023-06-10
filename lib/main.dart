import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fighting_gonggang/login/login.dart';
import 'package:fighting_gonggang/Maintab/Maintab.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fighting_gonggang/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* main 함수가 존재하는 구역
* 각종 이니셜라이징, 테마 설정이 이루어지는 곳
* 이니셜라이징 이후 바로 LoginPage로 이동
*
*
*
*
*
 */

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Color theme = Colors.green;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.green,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: theme,
            unselectedItemColor: theme,
            selectedItemColor: Colors.greenAccent,
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            elevation: 10,
          ),
          dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
          textTheme: GoogleFonts.gamjaFlowerTextTheme().copyWith(
            bodyMedium: const TextStyle(fontSize: 20.0),
            titleSmall: const TextStyle(fontSize: 20.0),
            bodySmall: const TextStyle(fontSize: 20.0),
            bodyLarge: const TextStyle(fontSize: 20.0),
            titleLarge: const TextStyle(fontSize: 20.0),
            labelMedium: const TextStyle(fontSize: 20.0),
            labelLarge: const TextStyle(fontSize: 20.0),
            labelSmall: const TextStyle(fontSize: 20.0),
            displayLarge: const TextStyle(fontSize: 20.0),
            displayMedium: const TextStyle(fontSize: 20.0),
            displaySmall: const TextStyle(fontSize: 20.0),
            titleMedium: const TextStyle(fontSize: 20.0),
          )),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],

      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko', 'KR'),
      darkTheme: ThemeData(
        primarySwatch: Colors.yellow,
        colorScheme: const ColorScheme.dark(background: Colors.black),
        textTheme: const TextTheme(
          labelLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.green),
          bodySmall: TextStyle(color: Colors.green),
        ),
      ),

      initialRoute: '/',
      // 앱에서 기본으로 실행될 페이지( 여기선 로그인)
      routes: {
        //routes: key=라우트명 ex:localhost:8080/라우트명
        '/': (context) => const LoginPage(),
        '/home': (context) => const MainTabPage(),
      },
    );
  }
}
