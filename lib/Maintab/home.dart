import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatelessWidget {

  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간


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
        onWillPop: ()  async {
      if (_lastPressedTime == null ||
          DateTime.now().difference(_lastPressedTime!) > Duration(seconds: 2)) {
        // 첫 번째 뒤로가기 버튼 클릭 시
        _lastPressedTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('한 번 더 누르면 종료됩니다.')),
        );
        return false; // 뒤로가기 버튼 막음
      } else {
        // 두 번째 뒤로가기 버튼 클릭 시
        SystemNavigator.pop(); // 앱을 종료시킴
        return true;
      }
    },
        child: Scaffold(
          body: Container(

            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder(
                  future: getCurrentLocation(),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    if (snapshot.hasData == false) {
                      return CircularProgressIndicator();
                    }
                    //error가 발생하게 될 경우 반환하게 되는 부분
                    else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(fontSize: 15),
                        ),
                      );
                    }
                    // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                    else {
                      final Position position = snapshot.data;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: KakaoMapView(
                            width: 500,
                            height: 300,
                            kakaoMapKey: dotenv.env["KAKAO_MAP_KEY"].toString(),
                            lat: position.latitude,
                            lng: position.longitude,
                            showMapTypeControl: true,
                            showZoomControl: true,
                            markerImageURL:
                            'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                            onTapMarker: (message) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(message.message)));
                            }),
                      );
                    }


                  },
                ),

              ],
            ),
          ),
          drawer: Drawer(
            child: dashboard(),
          ),
        )
    );
  }


}

