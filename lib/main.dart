import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'test/set_state.dart';
import 'test/test2.dart';
import './theme.dart' as theme123;

//이렇게하면 theme123에 './theme.dart'에 있는 모든 것이 들어감
//import해서 다른 페이지에 있는 변수 불러오는데 지금 페이지에 있는 변수랑 이름이 같으면
//충돌나거나 작동이 꼬일 수 있으니 이런식으로 구별을 한다고 한다.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => UserStore(),
        child: MaterialApp(home: Test(), theme: theme123.Themedata.light()));
  }
}
//store가 여러개면 ChangeNotifierProvider말고 MultiProvider를 쓰면 됨 
//providers 프로퍼티에 ChangeNotifierProvider()를 전부 넣어주면 된다. 
