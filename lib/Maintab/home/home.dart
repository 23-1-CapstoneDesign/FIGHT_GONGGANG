import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatelessWidget {
  Future<Position> getCurrentLocation() async {
// 위치 권한을 요청하고 위치 정보를 가져옴
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
// 위치 권한이 거부되었을 경우 null을 반환
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 이전 페이지로 이동하지 않고 원하는 동작을 수행
        // 예를 들면 다이얼로그 표시 등
        return false; // true를 반환하면 이전 페이지로 이동
      },
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("시간표"),
            ],
          ),
        ),
        drawer: Drawer(
          child: dashboard(),
        ),
      ),
    );
  }
}
