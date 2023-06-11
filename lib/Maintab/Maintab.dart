import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:fighting_gonggang/Maintab/comunity/community_main.dart';
import 'home/home.dart';
import 'package:fighting_gonggang/Maintab/mypage/mypage.dart';
import 'package:fighting_gonggang/Maintab/party/party_main.dart';
import 'package:fighting_gonggang/Maintab/map/map.dart';



class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  MainTabPageState createState() => MainTabPageState();
}

class MainTabPageState extends State<MainTabPage> {

  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomePage(),
    const PartyPage(),
    const  MapPage(),
      CommunityPage(),
    const  MyPage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Align(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ const SizedBox(),IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add))],))),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Party',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "지도",
            backgroundColor: Colors.deepOrange

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'MyPage',
          ),

        ],
      ),
      drawer: const Drawer(child: Dashboard()),
    );
  }

  void onTabTapped(int index) async{
    if (index == 2) {
     await Permission.location.request();
      Permission.location.status.then((val) {
        if (val.isDenied) {
          Permission.location.request().then((val) {
            if (val.isDenied) {
              Fluttertoast.showToast(
                msg: "위치 권한이 거부되어 사용할 수 없습니다.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MapPage()));
            }
          });
        }
        else{
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const MapPage()));
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
