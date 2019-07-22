import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todolist/model/Todo.dart';

class NewsListPage extends StatefulWidget {
  
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  
  bool _isLoading = false;
  List<Todo> _todo = [];


  Future<dynamic> fetchPosts() {
    _isLoading = true;

    return http
        .get('https://apitodo.hudya.xyz/todo')
        .then((http.Response response) {
      final List<Todo> fetchedPosts = [];
      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var rest = data["values"] as List;
        print(rest);  
      }

      var data = json.decode(response.body);
      final List<dynamic> postsData = data["values"];
      if (postsData == null) {
        setState(() {
          _isLoading = false;
        });
      }

      for (var i = 0; i < postsData.length; i++) {
        final Todo todo = Todo(
            id: postsData[i]['id'],
            title: postsData[i]['title'],
            description: postsData[i]['description']);
        fetchedPosts.add(todo);
      }

      setState(() {
        _todo = fetchedPosts;
        _isLoading = false;
      });
    }).catchError((Object error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

 Future<List<Todo>> getData() async {
  List<Todo> list;
    String link =
          "https://apitodo.hudya.xyz/todo";
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    print(res.body);
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        var rest = data["values"] as List;
        print(rest);
        list = rest.map<Todo>((json) => Todo.fromJson(json)).toList();
      }
    print("List Size: ${list.length}");
    return list;
  }
  
  Widget listViewWidget(List<Todo> article) {
    return Container(
      child: ListView.builder(
          itemCount: 20,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (context, position) {
            return Card(
              child: ListTile(
                title: Text(
                  '${article[position].title}',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () => _onTapItem(context, article[position]),
              ),
            );
          }),
    );
  }

  void _onTapItem(BuildContext context, Todo article) {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (BuildContext context) => NewsDetails(article, widget.title)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("TODO"),
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            return snapshot.data != null
                ? listViewWidget(snapshot.data)
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}