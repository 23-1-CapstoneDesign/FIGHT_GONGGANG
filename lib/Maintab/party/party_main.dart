import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fighting_gonggang/Layout/Dashboard.dart';
import '../../Layout/navbar.dart';

import 'party_popup.dart';

class Post {
  final String partyName;
  final String tag;
  final int currentMembers;
  final int totalMembers;
  final String? description;

  Post({
    required this.partyName,
    required this.tag,
    required this.currentMembers,
    required this.totalMembers,
    this.description,
  });
}

class PartyPage extends StatefulWidget {
  DateTime? _lastPressedTime; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  _PartyPageState createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  List<Post> posts = [
    Post(partyName: '파티1', tag: ' #태그1', currentMembers: 3, totalMembers: 5),
    Post(partyName: '파티2', tag: ' #태그2', currentMembers: 2, totalMembers: 4),
    Post(partyName: '파티3', tag: ' #태그3', currentMembers: 1, totalMembers: 3),
    Post(partyName: '파티4', tag: ' #태그4', currentMembers: 4, totalMembers: 6),
    // 추후 DB연결
  ];

  String searchText = '';

  List<Post> get filteredPosts {
    return posts.where((post) {
      final partyNameLower = post.partyName.toLowerCase();
      final tagLower = post.tag.toLowerCase();
      final searchLower = searchText.toLowerCase();
      return partyNameLower.contains(searchLower) ||
          tagLower.contains(searchLower);
    }).toList();
  }

  void showPartyDetails(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PartyDetailsPopup(
          partyName: post.partyName,
          tag: post.tag,
          currentMembers: post.currentMembers,
          totalMembers: post.totalMembers,
          description: post.description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파티 목록'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: '검색',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return ListTile(
                  title: Text(post.partyName),
                  subtitle: Text(
                      '태그 : ${post.tag} | 현재 인원 : ${post.currentMembers}/${post.totalMembers}'),
                  // 게시글 내용을 표시
                  onTap: () {
                    showPartyDetails(context, post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
