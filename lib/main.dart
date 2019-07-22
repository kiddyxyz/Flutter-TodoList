import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/Todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Http Request Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> _todo = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    fetchPosts();
  }

  Future<dynamic> fetchPosts() {
    _isLoading = true;

    return http
        .get('https://apitodo.hudya.xyz/todo')
        .then((http.Response response) {
      final List<Todo> fetchedPosts = [];

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

  Future<dynamic> createTodo(title, description) async{
      Map<String, String> body = {
       'title': title,
       'description': description,
      };

      var url = "https://apitodo.hudya.xyz/todo";

        return await http
            .post(Uri.encodeFull(url), body: body, headers: {"Accept":"application/json"})
            .then((http.Response response) {
              var data = json.decode(response.body);

            final int statusCode = response.statusCode;
            if (statusCode < 200 || statusCode > 400 || json == null) {
              throw new Exception("Error while fetching data");
            } 

            if(data["code"] == 200){
                return data["message"];
              }
              else{
                return false;
              }
        });
  }

  Future<dynamic> deleteTodo(id, title, description, status) async{
      Map<String, String> body = {
       'id': id,
       'title': title,
       'description': description,
       'status': status,
      };

      print(body);

      var url = 'https://apitodo.hudya.xyz/todo/${id}';
      print(url);
        return await http
            .put(Uri.encodeFull(url), body: body, headers: {"Accept":"application/json"})
            .then((http.Response response) {
              var data = json.decode(response.body);
            final int statusCode = response.statusCode;
            if (statusCode < 200 || statusCode > 400 || json == null) {
              throw new Exception("Error while fetching data");
            } 

            if(data["code"] == 200){
                return data["message"];
              }
              else{
                return false;
              }
        });
  }

  Future<dynamic> _onRefresh() {
    return fetchPosts();
  }

  final _formKey = GlobalKey<FormState>();
  var _idTodo = null;

  Widget _buildPostList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      key: _refreshIndicatorKey,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Padding(
                child: new ListTile(
                  title: Text(_todo[index].title),
                  subtitle: Text(_todo[index].description),
                  onLongPress: () {
                    _idTodo = _todo[index].id;
                    print(_idTodo);
                    return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete this todo?'),
        content: const Text(
            "You can't undo this action!"),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: const Text('ACCEPT'),
            onPressed: () async {
              var res = await deleteTodo(_idTodo.toString(), _todo[index].title, _todo[index].description, "N");
              if(res == null){
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Failed", "Something Wrong!");
                                }
                                else{
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Success", res);
                                  fetchPosts();
                                }
            },
          )
        ],
      );
    },
  );
                  },
                  onTap: () {
                    _idTodo = _todo[index].id;
                    titleText.text = _todo[index].title;
                    descText.text = _todo[index].description;
                    showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Update Todo"),
                          Text("Title"),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: titleText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          Text("Description"),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: descText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text("Submit"),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                }

                                var res = await deleteTodo(_idTodo.toString(), titleText.text, descText.text, "Y");
                                if(res == null){
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Failed", "Something Wrong!");
                                }
                                else{
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Success", res);
                                  fetchPosts();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
                  },
                ),
                padding: EdgeInsets.all(10.0),
              ),
              Divider(
                height: 5.0,
              )
            ],
          );
        },
        itemCount: _todo.length,
      ),
    );
  }

  final titleText = TextEditingController();
  final descText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todolist - Hudya'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildPostList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Title"),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: titleText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          Text("Description"),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: descText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              child: Text("Submit"),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                }

                                var res = await createTodo(titleText.text, descText.text);

                                if(res == null){
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Failed", "Something Wrong!");
                                }
                                else{
                                  Navigator.of(context).pop();
                                  alertDialog(context, "Success", res);
                                  fetchPosts();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

Future<void> alertDialog(context, title, message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}