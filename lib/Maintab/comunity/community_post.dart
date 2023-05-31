import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostPage extends StatefulWidget {
  final String boardType;

  const PostPage({Key? key, required this.boardType}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String _title = '';
  String _content = '';
  String _tags = '';
  File? _imageFile; // 선택된 이미지 파일

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedBoard;

  // 이미지 선택 및 미리보기 처리
  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery, // 갤러리에서 이미지 가져오기
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showBoardSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('게시판 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('자유 게시판'),
              onTap: () {
                setState(() {
                  _selectedBoard = '자유 게시판';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글 작성'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: _showBoardSelectionDialog,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.arrow_drop_down),
                    SizedBox(width: 8),
                    Text(
                      _selectedBoard ?? '게시판 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            SizedBox(height: 30),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _content = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: '태그(쉼표로 구분)',
                hintText: '#정보글, #홍보글, #삽니다, #팝니다',
                hintStyle: TextStyle(
                  color: Colors.grey[400], // 힌트 텍스트 색상 설정
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _tags = value;
                });
              },
            ),
            // 이미지 첨부 버튼
            InkWell(
              onTap: _getImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text(
                      '이미지 ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 선택된 이미지 미리보기
            if (_imageFile != null) ...[
              SizedBox(height: 16),
              Container(
                height: 200,
                child: Image.file(_imageFile!),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('등록'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 작성된 게시글 데이터를 서버에 전송하거나, 로컬 저장소에 저장하는 등의 작업 수행
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
