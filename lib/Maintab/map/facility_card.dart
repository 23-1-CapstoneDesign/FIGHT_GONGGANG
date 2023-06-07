import 'package:fighting_gonggang/Layout/items.dart';
import 'package:fighting_gonggang/Maintab.dart';
import 'package:fighting_gonggang/Maintab/home/gallery_policy.dart';
import 'package:fighting_gonggang/Maintab/timetable/AddClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fighting_gonggang/Maintab/timetable/Timetable.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class FacCard extends StatefulWidget {
  String facility;

  FacCard({this.facility = ""});

  @override
  _FacCardState createState() => _FacCardState();
}

// class HomePage extends StatelessWidget {
class _FacCardState extends State<FacCard> {
  static final dburl = dotenv.env["MONGO_URL"].toString();
  List<String> name = [];
  List<String> datelist = [];
  List<Map<String, dynamic>> names = [];
  String facility = "";

  void setFacility(String facility) async {
    int index = names.indexWhere((element) => element['facility'] == facility);

    print(index);

    if (index != -1 && mounted) {
      print(names[index]);

      setState(() {
        name = List<String>.from(names[index]['names']);
      });
    } else if (mounted) {
      setState(() {
        name = [];
      });
    }

    // name=List<String>.from();
    // print(name);
  }

  void getReservation(String name) async {
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('facility');

    var find = await collection.find({"name": name}).toList();
    List<Map<String, dynamic>> i = find;
    final pipeline = [
      {
        '\$match': {'name': name}
      },
      {
        '\$group': {
          '_id': null,
          'day': {'\$addToSet': '\$day'}
        }
      },
      {
        '\$project': {'_id': 0, 'day': 1}
      }
    ];
    List<Map<String, dynamic>> result =
        await collection.aggregateToStream(pipeline).toList();
    // print(result[0]['day'].runtimeType);
    setState(() {
      datelist = List<String>.from(result[0]['day']);

    });
    print(datelist);
  }

  void getName() async {
    mongo.Db conn = await mongo.Db.create(dburl);
    await conn.open();
    mongo.DbCollection collection = conn.collection('facility');

    final pipeline = [
      {
        '\$group': {
          '_id': '\$facility',
          'names': {'\$addToSet': '\$name'},
        },
      },
      {
        '\$project': {
          '_id': 0,
          'facility': '\$_id',
          'names': 1,
        },
      },
    ];
    List<Map<String, dynamic>> result =
        await collection.aggregateToStream(pipeline).toList();

    if (mounted) {
      setState(() {
        names = result;
      });

      // names['values'].map((dynamic value) => value as String));
    }
    conn.close();
  }

  @override
  void didUpdateWidget(FacCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // facility 값이 변경될 때마다 호출되는 함수
    if (widget.facility != facility) {
      facility = widget.facility;

      setFacility(facility);
    }
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    if (facility != "") {
      // setFacility(facility);
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 150,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: name.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ElevatedButton(
                          onPressed: () {
                            getReservation(name[index]);
                          },
                          child: Text(name[index]));
                    }),
              ),
              if (name.isNotEmpty)
                SizedBox(
                  height: 300,
                  width: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text("예약 현황")),
                        SizedBox(
                            width: 250, child: FGRoundTextField(text: "시설명:")),
                        SizedBox(
                            height: 40,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: datelist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // return ElevatedButton(
                                  // onPressed: () {}, child: Text(datelist[index]));
                                  // })),
                                  return Text("");
                                }))
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      return Column();
    }
  }
}
