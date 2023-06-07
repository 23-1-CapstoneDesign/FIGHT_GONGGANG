import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'Maintab.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

/*
* main 함수가 존재하는 구역
* 전역적으로 데이터를 로드할 일이 있다면 이곳에 넣으면 될듯... 이 이상은 저도 잘 몰라용
*
* 라우팅(주소창에 입력될 주소명)명을 지정하려면 아래에서 작성하면 됩니당.
*
 */

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Color theme = Colors.green;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Form',
      theme: ThemeData(
          primarySwatch: Colors.green,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: theme,
            unselectedItemColor: theme,
            selectedItemColor: Colors.greenAccent,
            unselectedIconTheme: IconThemeData(color: Colors.black),
            elevation: 10,
          ),
          dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
          textTheme: GoogleFonts.gamjaFlowerTextTheme()
              .copyWith(bodyMedium: TextStyle(fontSize: 20.0),)),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],

      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
      locale: Locale('ko', 'KR'),
      darkTheme: ThemeData(
        primarySwatch: Colors.yellow,
        colorScheme: const ColorScheme.dark(background: Colors.black),
        textTheme: TextTheme(
          labelLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.green),
          bodySmall: TextStyle(color: Colors.green),
        ),
      ),

      initialRoute: '/',
      // 앱에서 기본으로 실행될 페이지( 여기선 로그인)
      routes: {
        //routes: key=라우트명 ex:localhost:8080/라우트명
        '/': (context) => LoginPage(),
        '/home': (context) => MaintabPage(),
      },
    );
  }
}
