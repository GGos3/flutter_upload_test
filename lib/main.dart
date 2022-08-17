import 'package:flut_3/Theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import "dart:io";
import 'package:flutter/src/rendering/box.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: theme,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  var tab = 0;
  var data = [];
  var userImage;

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Instagram",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => Upload(
                        userImage: userImage,
                        data: data)), //=> 는 return(이랑 똑같음)
              ).then(((value) {
                print("asd");
                setState(() {});
              }));
            },
            iconSize: 30,
          )
        ],
      ),
      body: PageView(
        controller: PageController(
          initialPage: 0, //0번째를 먼저 보여줌
        ),
        children: [
          Post(data: data),
          Text("샵"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false, //선택한 라벨 이름 보여주기
        showUnselectedLabels: false, //선택안된 라벨 이름 보여주기
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: "샵"),
        ],
      ),
    );
  }
}

class Post extends StatefulWidget {
  Post({Key? key, this.data}) : super(key: key);
  var data;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  getmoredata() async {
    var moredata = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more2.json'));
    var moredata2 = jsonDecode(moredata.body);
    setState(() {
      widget.data.add(moredata2);
    });
  }

  var scroll = ScrollController();

  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getmoredata();
      }
    });
  }

  setImage(i) {
    if (widget.data[i]["image"].runtimeType == String) {
      return Image.network(
        widget.data[i]["image"],
        fit: BoxFit.fill,
      );
    } else {
      return Image.file(
        widget.data[i]["image"],
        fit: BoxFit.fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
        controller: scroll,
        itemCount: widget.data.length,
        itemBuilder: (c, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              setImage(i),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "좋아요 ${widget.data[i]['likes']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.data[i]['date']),
                      Text(widget.data[i]['content']),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      );
    } else {
      return Text("로딩중");
    }
  }
}

class Upload extends StatefulWidget {
  Upload({Key? key, this.userImage, this.data}) : super(key: key);
  final data;
  var userImage;

  final TextEditingController text = TextEditingController();
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  var now = DateFormat.MMMd('en_US').format(DateTime.now());

  addpost(context, userImage, text) {
    if (userImage != null) {
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              userImage,
              fit: BoxFit.fitWidth,
              height: 300,
              width: double.infinity,
            ),
            SizedBox(
                width: 300,
                child: TextField(
                  controller: text,
                ))
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              addpost(context, widget.userImage, widget.text),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.data.insert(0, {
                      "id": widget.data.length,
                      "image": widget.userImage,
                      "likes": 0,
                      "date": now,
                      "content": widget.text.text,
                      "user": "사람"
                    });
                  });

                  Navigator.pop(context);
                },
                child: Text(
                  "게시",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]));
  }
}