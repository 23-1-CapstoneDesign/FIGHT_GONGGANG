import 'dart:async';

import 'package:fighting_gonggang/Maintab/map/facility_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';

import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';

enum ButtonState { idle, pressed }

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

// class MapPage extends StatelessWidget {
class _MapPageState extends State<MapPage> {
  ButtonState _button1State = ButtonState.idle;
  ButtonState _button2State = ButtonState.idle;
  ButtonState _button3State = ButtonState.idle;

  static final dburl = dotenv.env["MONGO_URL"].toString();
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간
  double max_lat = 36.801758;
  double max_lng = 127.069522;
  double min_lat = 36.794258;
  double min_lng = 127.078673;
  late WebViewController webViewController;
  late Timer _timer;

  int selected_index = -1;

  bool _isFirst = true;
  bool type = true;

  var x = 36.798786;
  var y = 127.074959;

  final points = [
    [36.800262, 127.074934, "본관"], //본관 위치
    [36.800171, 127.072652, "공학관"], //공학관 위치
    [36.800080, 127.077211, "원화관"], //원화관 위치
    [36.798791, 127.074048, "자연관"], //자연관 위치
    [36.798791, 127.075871, "인문관"], //인문관 위치
    [36.798839, 127.078338, "보건관"]
  ];

  final point_bon = [36.800262, 127.074934, "본관"]; //본관 위치
  final point_gonghak = [36.800171, 127.072652, "공학관"]; //공학관 위치
  final point_wonhwa = [36.800080, 127.077211, "원화관"]; //원화관 위치
  final point_jayeon = [36.798791, 127.074048, "자연관"]; //자연관 위치
  final point_inmoon = [36.798791, 127.075871, "인문관"]; //인문관 위치
  final point_bogeon = [36.798839, 127.078338, "보건관"]; //보건관 위치

  Future<String> test() async {
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    var find = await collection.find({'username': 'admin'}).toList();
    conn.close();
    return find.toString();
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      getCurrentLocation().then((value) {
        if (mounted) {
          setState(() {
            x = value.latitude;
            y = value.longitude;

            webViewController.runJavascript('''
      markers = [];
      

  var mapLinks = document.querySelectorAll('a');
  if(mapLinks.length!=0){
  mapLinks.forEach(function(link) {
    link.parentNode.removeChild(link);
  });
  }
      
      function addMarker(position) {
        let imageSrc = 'https://cdn0.iconfinder.com/data/icons/map-36/20/marker_person-512.png'; // 마커이미지의 주소    
        let imageSize = new kakao.maps.Size(20, 20); // 마커이미지의 크기
        let imageOption = {offset: new kakao.maps.Point(1, 1)};


        // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
        let markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption);

        let marker = new kakao.maps.Marker({
          position: position,
          image: markerImage
        });

        markers.push(marker);

        marker.setMap(map);
      }

      function deleteMarker() {

              markers[0].setMap(null);
      }

      addMarker(new kakao.maps.LatLng(${x} , ${y} ));
      setTimeout(()=>{
        deleteMarker();
      }, 300);
    ''');

            _isFirst = false;
          });
        }
      });
    });

// 위치 권한이 거부되었을 경우 null을 반환
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  Future<Position> getCurrentLocation() async {
// 위치 권한을 요청하고 위치 정보를 가져옴

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("지도")),
      body: Column(children: [
        SizedBox(height: 20),
        Align(
            child: KakaoMapView(
                width: 350,
                height: 300,
                kakaoMapKey: dotenv.env["KAKAO_MAP_KEY"].toString(),
                mapController: (controller) {
                  webViewController = controller;
                },
                lat: x,
                lng: y,
                showMapTypeControl: true,
                showZoomControl: true,
                markerImageURL:
                    'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                customScript: '''

            var markers = [];

            function addMarker(position) {

    var marker = new kakao.maps.Marker({position: position});

    marker.setMap(map);

    markers.push(marker);
    }
var iwContent = '<div style="padding:5px;">Hello World!</div>', // 인포윈도우에 표출될 내용으로 HTML 문자열이나 document element가 가능합니다
    iwRemoveable = true; // removeable 속성을 ture 로 설정하면 인포윈도우를 닫을 수 있는 x버튼이 표시됩니다

// 인포윈도우를 생성합니다
var infowindow = new kakao.maps.InfoWindow({
    content : iwContent,
    removable : iwRemoveable
});

      addMarker(new kakao.maps.LatLng(${point_bon[0]},${point_bon[1]}));
      addMarker(new kakao.maps.LatLng(${point_gonghak[0]},${point_gonghak[1]}));
      addMarker(new kakao.maps.LatLng(${point_inmoon[0]},${point_inmoon[1]}));
      addMarker(new kakao.maps.LatLng(${point_jayeon[0]},${point_jayeon[1]}));
      addMarker(new kakao.maps.LatLng(${point_wonhwa[0]},${point_wonhwa[1]}));  
      addMarker(new kakao.maps.LatLng(${point_bogeon[0]},${point_bogeon[1]}));        
      kakao.maps.event.addListener(markers[0], 'click', (function() {
      

        return function(){
          onTapMarker.postMessage('본관');
          };
        }
        )(0)
      );
      
       kakao.maps.event.addListener(markers[1], 'click', (function() {
        return function(){
          onTapMarker.postMessage('공학관');
          };
        }
        )(1)
      );
      
       kakao.maps.event.addListener(markers[2], 'click', (function() {
        return function(){
          onTapMarker.postMessage('인문관');
          };
        }
        )(2)
      );
      
       kakao.maps.event.addListener(markers[3], 'click', (function() {
      
        return function(){
          onTapMarker.postMessage('자연관');
          };
        }
        )(3)
      );
      
       kakao.maps.event.addListener(markers[4], 'click', (function() {
      
        return function(){
          onTapMarker.postMessage('원화관 ');
          };
        }
        )(4)
      );
       kakao.maps.event.addListener(markers[5], 'click', (function() {
        return function(){
          onTapMarker.postMessage('보건관');
          };
        }
        )(5)
      );
    ''',
                onTapMarker: (message) {
                  Fluttertoast.showToast(
                    msg: message.message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  try {
                    setState(() {
                      selected_index = points.indexWhere(
                          (element) => element[2] == message.message);
                    });
                  } catch (e) {}
                })),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 20,
          child: ListView.builder(
              scrollDirection: Axis.horizontal, // 수평 스크롤을 위해 설정
              itemCount: points.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < points.length) {
                  return ElevatedButton(
                      onPressed: () {
                        webViewController.runJavascript('''
      map.setCenter(new kakao.maps.LatLng(${points[index][0]}, ${points[index][1]}));
      ''');

                        setState(() {
                          selected_index = index;
                        });
                      },
                      child: Text(points[index][2].toString()));
                } else {
                  return ElevatedButton(
                      onPressed: () {
                        webViewController.runJavascript('''
      map.setCenter(new kakao.maps.LatLng(${x}, ${y}));
      ''');
                      },
                      child: Text("현위치"));
                }
              }),
        ),
        SizedBox(
          height: 30,
        ),
          FacCard(facility: selected_index!=-1?points[selected_index][2].toString():""),
      ]),
    );
  }
}
