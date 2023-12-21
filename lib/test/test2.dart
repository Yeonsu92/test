import 'dart:collection';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert'; //json->일반 함수식으로 바꿔주는 라이브러리
//json은 자바스크립트에서 자료를 주고받을때 쓰는 자료형, 문자열로만 이루어져있음
//서버랑 통신할때는 문자만 주고받을 수 있어서 [](리스트) {}(맵) 는 전송이 안되는데
//[] {} 안에 따옴표 쳐서 문자인척 사기치면 주고받을 수 있음
//그래서 json자료에는 큰따옴표가 많다.
//모든 정보가 문자열이라서 원하는 데이터 불러오기가 어려움.
//그래서 json자료를 [] {}로 바꿔주는게 필요한데 dart:convert 라이브러리에 있는 함수 가져다쓰면 편함.
//get요청할 거 많으면 dio 라이브러리 쓰는게 좋다고함 http보다 편리해서.
import 'package:flutter/rendering.dart'; //<- 스크롤 위치 다룰때 유용한 함수가 많은 기본패키지라 함
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class UserStore extends ChangeNotifier {
  int follower = 0;
  bool isFollowed = false;
  var profileImage = [];

  void follow() {
    if (!isFollowed) {
      follower++;
      isFollowed = true;
    } else {
      follower--;
      isFollowed = false;
    }
    notifyListeners();
  }

  getProfileImage() async {
    var resultJson = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result = jsonDecode(resultJson.body);

    if (result == null) {
      debugPrint('이미지없음!');
      return;
    }
    profileImage = result;
    notifyListeners();
    print(result);
  }
}
//store:보관함
//context.watch<UserStore>().user; 변수 읽기모드
//context.read<UserStore>().user; 함수쓸때

class Test extends StatefulWidget {
  Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  var tab = 0;
  var data = [];

  getData() async {
    var resultJson = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    if (resultJson.statusCode == 200) {
      debugPrint('데이터 가져오기 성공');
    } else {
      debugPrint('데이터 가져오기 실패');
    }

    var result = jsonDecode(resultJson.body);
    setState(() {
      data = result;
    });
    //print(result);
  }

  addData(a) {
    setState(() {
      data.add(a);
    });
  }

  getPost(userImage, userContent) {
    if (userContent == '' || userImage == null) {
      debugPrint('내용을 입력해야합니다.');
      return;
    }
    Map userPost = {
      'id': data.length,
      //'image': userImage.path,
      'image': userImage.runtimeType == String ? userImage : userImage.path,
      //모바일로 받을 땐 이미지가 String이 아니라 _File로 와서 image.network가 아니라 image.file써줘야해서
      //이렇게 나눠받는 코드를 짜보면 좋을 것 같은데 잘 모르겠음
      'likes': 0,
      'date': 'Feb 29',
      'content': userContent,
      'liked': false,
      'user': 'USER',
    };
    setState(() {
      data.insert(0, userPost);
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: tab ==0 ? Text('홈') : Text('쇼핑'),
      body: [
        HomeScreen(
          data: data,
          addData: addData,
        ),
        Text('쇼핑')
      ][tab],
      appBar: AppBar(centerTitle: false, title: const Text('A'), actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (contextNavi) {
                return Upload(getPost: getPost);
              }));
            },
            icon: const Icon(Icons.add_box_outlined))
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          tab = index;
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ''),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.data, required this.addData});
  final List data;
  final Function addData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController(); //스크롤 저장함
  int count = 0;

  getMore() async {
    if (count == 1) {
      return;
    }
    var data2 = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
//Rejecting promise with error: Flutter Web engine failed to complete HTTP request to fetch "assets/FontManifest.json": TypeError: Failed to fetch
    var result = jsonDecode(data2.body);
    widget.addData(result);
    count++;
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getMore();
      }
    });
    //Listener: 왼쪽에 있는 변수가 변할때마다 오른쪽 {}을 실행 : 스크롤 위치가 바뀔때마다 실행되는 함수
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.data.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: scrollController,
            itemCount: widget.data.length,
            itemBuilder: (context, i) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.data[i]['image'].runtimeType == String
                        ? Image.network(
                            widget.data[i]['image'],
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            widget.data[i]['image'],
                            fit: BoxFit.cover,
                          ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    context.read<UserStore>().getProfileImage();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) => UserProfile(
                                                  data: widget.data,
                                                  id: i,
                                                ))));
                                  },
                                  child: Text('${widget.data[i]['user']}')),
                              const Expanded(child: SizedBox()),
                              Text(
                                '좋아요 ${widget.data[i]['likes']}개',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text('${widget.data[i]['content']}'),
                        ],
                      ),
                    )
                  ]);
            });
  }
}

//----------------- 트윗 업로드 페이지 -----------------
class Upload extends StatefulWidget {
  const Upload({Key? key, required this.getPost}) : super(key: key);
  final Function getPost;

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  XFile? file;
  TextEditingController contentCtrl = TextEditingController();

  void addFile() async {
    const typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    final result = await openFile(acceptedTypeGroups: [typeGroup]);
    if (result == null) {
      return;
    }
    setState(() {
      file = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              onPressed: () {
                widget.getPost(file, contentCtrl.text);
              },
              child: const Text('Submit'),
            )
          ],
        ),
        body: ListView(
          children: [
            file == null
                ? Container(
                    color: Colors.black12,
                    height: 200,
                    child: const Center(child: Text('이미지를 선택해주세요')))
                : file!.path.runtimeType == String
                    ? Image.network(
                        file!.path,
                        height: 200,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(file!.path),
                        height: 200,
                        fit: BoxFit.contain,
                      ),
            const SizedBox(height: 5),
            SizedBox(
              height: 100,
              child: TextField(
                maxLines: 5,
                controller: contentCtrl,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(20),
                  hintText: '내용을 입력해주세요',
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        addFile();
                      },
                      icon: const Icon(Icons.add, color: Colors.white)),
                ),
              ],
            ),
          ],
        ));
  }
}

//------------ 프로필 -------------
class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.data, required this.id});

  final List data;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data[id]['user']),
        actions: [
          IconButton(
              onPressed: () {
                // context.read<UserStore>().getProfileImage();
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
            CircleAvatar(
              backgroundImage: NetworkImage(data[id]['image']),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text('팔로워 ${context.watch<UserStore>().follower}명')),
            //???stateless안인데 어떻게 위젯이 다시 그려지는 걸까?
            ElevatedButton(
                onPressed: () {
                  context.read<UserStore>().follow();
                },
                child: Text('팔로우')),
          ]),
        ),
        GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          //shrinkWrap: true,
          itemCount: context.watch<UserStore>().profileImage.length,

          itemBuilder: (context, i) {
            //return Container(color: Colors.blue);
            return context.watch<UserStore>().profileImage.isEmpty
                ? SizedBox()
                : Image.network(context.watch<UserStore>().profileImage[i]);
          },
        ),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.network(
        //       context.watch<UserStore>().profileImage[0]['image']),
        // ),
      ]),
    );
  }
}

//clone파일에서 수정함 
