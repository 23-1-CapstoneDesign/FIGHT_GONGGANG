# Project:싸우자 공강아

## 프로젝트 개요 
선문대생을 위한 공강활용 증진 프로그램

## 프로젝트 목적 
1.자율적으로 만든 대학 수업 시간표 속에서 생기는 공강 시간의 활용도를 높이기 위함.
2.학교를 적극적으로 이용하고적응할 수 있도록 도움을 주기 위함.


## 사용 기술 및 도구
```
사용언어:Dart-flutter,javascript
데이터베이스: MongoDB,Firebase
개발 환경: VScode, AndroidStudio
개발 플랫폼: Android,ios(ios도 실행은 가능하나 권한 부여 등 사전작업이 필요할 것으로 보임)
```

## 


## 프로젝트 실행시 요구 파일


개인정보가 포함되어 있으므로 깃허브에 등록되지 않는 파일들의 목록

---

[백엔드](https://github.com/23-1-CapstoneDesign/Server)
python 3.9 요구(3.8도 상관없으나 3.9버전 권장)


---
파일 명:.env

파일 위치: 프로젝트 최상위 폴더  
```

KAKAO_MAP_KEY="KAKAO MAP JAVASCRIPT API KEY"

MONGO_URL="MONGO DB URL(mongodb+src://??~~~.mongodb.net/  형식)"
```
---
firebase_options.dart,google-services.json 외 firebase관련 파일

firebase에서 flutter앱 등록 필요 

[firebase 등록 방법](https://firebase.google.com/docs/flutter/setup?hl=ko&platform=android)

## 참고사항
구현을 위한 코드들은 lib폴더네에 있습니다.

Android,ios등의 폴더는 각 플랫폼의 실행을 위해 생성된 폴더로 권한 부여 등의 역할만 할 뿐 아무것도 없어요.

## 개선 해야 할 부분
- SQLite 적용 - MongoDB에서 받은 데이터를 담아 MongoDB와의 connect를 줄이면 실행 속도가 개선될 것으로 보임.

# author
장효택-[alwaystaegi](https://github.com/alwaystaegi)

심은정-[eundongg](https://github.com/eundongg)
