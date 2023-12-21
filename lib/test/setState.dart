import 'package:flutter/material.dart';

//setState 쓰는 법
//StatefulWidget 안에서 정의된 변수는 모두 state에 저장되어있음
//setState를 쓰면 변경된 state를 반영해 화면을 다시 그린다.
//변경하고 싶은 내용을 setState안에 넣으면 된다는데...
//근데 setState호출하면 해당 statefulWidget를 다시 다 그리는 것 같은데...
//이부분은 잘 모르겠음.
//----------------------
//부모위젯의 변수나 함수를 자식에게 파라미터로 상속하는법
//1.부모에서 파라미터로 만들기 2.자식에서 파라미터로 받기
//파라미터 상속은 부모->자식에서만 가능하며 역으로는 안됨, 형제?위젯에서도 안됨.

//자식위젯에서 부모위젯의 변수를 변경하고 싶으면 직접 변경하기보다는
//변경하는 함수를 부모위젯에 만들고 그걸 파라미터로 상속받아 자식위젯에서 호출하는 것이 좋다.
//이렇게 하면 부모위젯의 변수를 직접 변경하는 것이 아니라 부모위젯의 함수를 호출해서 변경하기 때문에
//부모위젯의 변수를 변경하는 것이다.

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<String> name = ["김", "이", "박"];
  List<int> like = [0, 0, 0];
  var total = 3; //이거 왜 name.length로 하면 안되는지 모르겠음
  final inputdata2 = TextEditingController();

  void init() {
    setState(() {
      {
        for (int i = 0; i < like.length; i++) {
          like[i] = 0;
        }
      }
    });
  }
  //setState안하면 like값은 초기화되는데 화면이 안그려짐

  void sortName() {
    setState(() {
      name.sort();
    });
  }

  void addName(a) {
    if (a != '') {
      name.add(a);
      like.add(0);
      setState(() {});
    }
  }

  //여기서 a는 파라미터
  //name.add(a)는 name리스트에 a를 추가하는거
  //이렇게 안짜면 다음과같이 되는데,
  void addName2() {
    if (inputdata2.text != '') {
      name.add(inputdata2.text);
      like.add(0);
      setState(() {});
    }
  }
  //이렇게하면 inputdata2도 파라미터로 만들어서 자식에게 상속시켜줘야됨. 그래서 처음걸로 하는 게 나아보인다.

  int getSum() {
    int sum = 0;
    for (int i = 0; i < like.length; i++) {
      sum += like[i];
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처'),
        actions: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                  onPressed: () {
                    sortName();
                  },
                  icon: const Icon(Icons.refresh)))
        ],
      ),
      body: ListView.builder(
        itemCount: name.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(like[index].toString()),
            ),
            title: Text(name[index]),
            trailing: Wrap(
              spacing: 3,
              children: [
                ElevatedButton(
                  child: const Text('좋아요'),
                  onPressed: () {
                    setState(() {
                      like[index]++;
                    });
                  },
                ),
                IconButton(
                    onPressed: () {
                      name.removeAt(index);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete))
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return DialogUI(sum: getSum(), init: init, addName: addName);
              });
        },
      ),
    );
  }
}

class DialogUI extends StatelessWidget {
  DialogUI(
      {super.key,
      required this.sum,
      required this.init,
      required this.addName});
  final int sum;
  final Function init;
  final Function addName;
  final inputData = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SizedBox(
      width: 300,
      height: 300,
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(20), child: Text('좋아요 합계: $sum')),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: inputData,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '추가할 이름을 입력해주세요.',
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    init();
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: TextButton(
                  child: const Text('완료'),
                  onPressed: () {
                    addName(inputData.text);
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }
}
