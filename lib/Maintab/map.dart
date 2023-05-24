import 'dart:async';

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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

// class MapPage extends StatelessWidget {
class _MapPageState extends State<MapPage> {
  static final dburl = dotenv.env["MONGO_URL"].toString();
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간
  double max_lat = 36.801758;
  double max_lng = 127.069522;
  double min_lat = 36.794258;
  double min_lng = 127.078673;
  bool isFirst = true;
  late WebViewController webViewController;
  late Timer _timer;

  var x = 36.798786;
  var y = 127.074959;

  Future<String> test() async {
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('users');

    var find = await collection.find({'username': 'admin'}).toList();

    return find.toString();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      getCurrentLocation().then((value) {
        setState(() {
          x = value.latitude;
          y = value.longitude;




          webViewController?.runJavascript('''
        markers=[];
        now=[];
        var moveLatLon = new kakao.maps.LatLng($x, $y);
        function sisulMarker(){
        var imgSrc="https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png";
        let imgsize = new kakao.maps.Size(15, 15); // 마커이미지의 크기
        let imgOption = {offset: new kakao.maps.Point(15, 15)};
        
        let sisulimage = new kakao.maps.MarkerImage(imgSrc, imgsize, imgOption);
        
        const jayeonposition = new kakao.maps.LatLng(36.798816,127.074024);
        var test= {test().then((result) {
           return result;
         })}
        let jayeonmarker = new kakao.maps.Marker({
          position: jayeonposition,
          image: sisulimage,
        });
        jayeonmarker.setMap(map);
      
        }
        if($isFirst){
        sisulMarker();
        map.setCenter(moveLatLon);
        }
        
        var mapContainer = document.getElementById('map') // 지도를 표시할 div 
        var mapOption = { 
        
        center: new kakao.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
        level: 3 // 지도의 확대 레벨
    };
    
function addMarker(){
        var imgSrc="https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png";
        let imgsize = new kakao.maps.Size(30, 30); // 마커이미지의 크기
        let imgOption = {offset: new kakao.maps.Point(15, 15)};
        
        let sisulimage = new kakao.maps.MarkerImage(imgSrc, imgsize, imgOption);
        
        const position = new kakao.maps.LatLng($x,$y);
        
        let marker = new kakao.maps.Marker({
          position: position,
          image: sisulimage,
        });
        marker.setMap(map);
        setTimeout(()=>{
         marker.setMap(null)
         },1000)
        now.push(marker);
        if(now.length==2){
          now[0].setMap(null);
        }
        }
         addMarker();
 
    // 이동할 위도 경도 위치를 생성합니다 

    
    // 지도 중심을 이동 시킵니다

 // map.setDraggable(false);  


    ''');
          setState(() {
            isFirst = false;
          });
        });
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
    return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: KakaoMapView(
            mapController: (p0) {
              webViewController = p0;
            },
            width: 500,
            height: 300,
            kakaoMapKey: dotenv.env["KAKAO_MAP_KEY"].toString(),
            lat: x,
            lng: y,
            showMapTypeControl: true,
            showZoomControl: true,
            markerImageURL:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
            onTapMarker: (message) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message.message)));
            }));
    //,
    //             ),
    //
    //
    //     ],
    //   ),
    // ),
    // drawer: Drawer(
    // child: dashboard(),
    // ),
    // );
  }
}
