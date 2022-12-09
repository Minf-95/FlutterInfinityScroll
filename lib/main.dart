import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testinfinity/photo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Photo> photos = [];
  bool loading = false;
  int albumId = 1;
  ScrollController _scrollController = ScrollController();



  Future<void> getPhotos(int albumId) async {
    if (albumId > 50) {
      return;
    }

    final String url =
        "https://jsonplaceholder.typicode.com/photos?albumId=$albumId";
    var uri = Uri.parse(url);

    try {
      // 처음이라면 중앙에 로딩 인디케이터가 나오게 함
      if (albumId == 1) {
        setState(() {
          loading = true;
        });
      }
      http.Response response = await http.get(uri);
      if (albumId == 1) {
        setState(() {
          loading = false;
        });
      }

      final items = json.decode(response.body);
      items.forEach((item) {
        photos.add(Photo.fromJson(item));
      });

      setState(() {});
    } catch (err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.red,
              title: Text("오류"),
              content: Text("오류가 났습니다."),
            );
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhotos(albumId);

    _scrollController.addListener(() {
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
        albumId++;
        getPhotos(albumId);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Infinite Scroll"),
      ),
      body: loading? Center(child: CircularProgressIndicator(),) :ListView.builder(
        controller: _scrollController,
          itemCount: photos.length+1,
          itemBuilder: (BuildContext context, index) {
          if(index==photos.length){
            return Center(child: CircularProgressIndicator(),);
          }
            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.network(
                      photos[index].url,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Text(photos[index].title),
                  ],
                ),
                Text('${index+1}', textAlign: TextAlign.center)
              ],
            );
          }),
    );
  }
}
