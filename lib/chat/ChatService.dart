// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> sendMessage(String message) async {
//     try {
//       // 채팅 메시지를 Firestore에 저장
//       await _firestore.collection('messages').add({
//         'message': message,
//         'timestamp': DateTime.now(),
//       });
//     } catch (e) {
//       print('채팅 메시지 전송 오류: $e');
//     }
//   }
//
//   void configureMessaging() {
//     // Firebase Cloud Messaging 구성 및 토큰 가져오기
//
//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         // 앱이 실행 중일 때 푸시 알림이 도착한 경우
//         print('푸시 알림이 도착했습니다: $message');
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         // 앱이 완전히 종료된 상태에서 푸시 알림을 통해 앱이 실행되는 경우
//         print('앱이 푸시 알림을 통해 실행되었습니다: $message');
//       },
//       onResume: (Map<String, dynamic> message) async {
//         // 앱이 백그라운드에서 실행 중일 때 푸시 알림을 통해 다시 포그라운드로 돌아온 경우
//         print('앱이 푸시 알림을 통해 다시 포그라운드로 돌아왔습니다: $message');
//       },
//     );
//
//     // 푸시 알림을 위한 토큰 가져오기
//     _firebaseMessaging.getToken().then((token) {
//       print('Firebase Messaging 토큰: $token');
//       // 토큰을 사용하여 사용자와 관련된 작업 수행
//       // 예: 서버에 토큰 등록, 푸시 알림 설정 등
//     }).catchError((err) {
//       print('Firebase Messaging 토큰 가져오기 오류: $err');
//     });
//   }
//
//   Stream<List<ChatMessage>> getChatMessages() {
//     // Firestore의 'messages' 컬렉션을 실시간으로 모니터링하여 채팅 메시지 가져오기
//     return _firestore.collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return ChatMessage(
//           message: doc['message'],
//           timestamp: doc['timestamp'].toDate(),
//         );
//       }).toList();
//     });
//   }
// }
//
// class ChatMessage {
//   final String message;
//   final DateTime timestamp;
//
//   ChatMessage({required this.message, required this.timestamp});
// }
