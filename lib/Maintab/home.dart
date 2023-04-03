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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      );
                    }


                  },
                ),
                KakaoMapView(
                    width: 200,
                    height: 300,
                    kakaoMapKey: dotenv.env["KAKAO_MAP_KEY"].toString(),
                    lat: 33.450701,
                    lng: 126.570667,
                    showMapTypeControl: true,
                    showZoomControl: true,
                    draggableMarker: true,
                    polyline: KakaoFigure(
                      path: [
                        KakaoLatLng(lat: 33.45080604081833, lng: 126.56900858718982),
                        KakaoLatLng(lat: 33.450766588506054, lng: 126.57263147947938),
                        KakaoLatLng(lat: 33.45162008091554, lng: 126.5713226693152)
                      ],
                      strokeColor: Colors.blue,
                      strokeWeight: 2.5,
                      strokeColorOpacity: 0.9,
                    ),
                    polygon: KakaoFigure(
                      path: [
                        KakaoLatLng(lat: 33.45086654081833, lng: 126.56906858718982),
                        KakaoLatLng(lat: 33.45010890948828, lng: 126.56898629127468),
                        KakaoLatLng(lat: 33.44979857909499, lng: 126.57049357211622),
                        KakaoLatLng(lat: 33.450137483918496, lng: 126.57202991943016),
                        KakaoLatLng(lat: 33.450706188506054, lng: 126.57223147947938),
                        KakaoLatLng(lat: 33.45164068091554, lng: 126.5713126693152)
                      ],
                      polygonColor: Colors.red,
                      polygonColorOpacity: 0.3,
                      strokeColor: Colors.deepOrange,
                      strokeWeight: 2.5,
                      strokeColorOpacity: 0.9,
                      strokeStyle: StrokeStyle.shortdashdot,
                    ),
                    markerImageURL:
                    'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                    onTapMarker: (message) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(message.message)));
                    }),
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

