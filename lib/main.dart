import 'dart:convert';
import 'package:dynatrace_flutter_plugin/dynatrace_flutter_plugin.dart';
import 'package:dynatracetestapp/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers() async {
  final response =
      await http.get(Uri.parse('https://reqres.in/api/users?page=1'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> usersData = data['data'];
    return usersData.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

void main() {
  Dynatrace().start(MyApp(),
      configuration: Configuration(
        reportCrash: true,
        monitorWebRequest: true,
        logLevel: LogLevel.Info,
        userOptIn: true,
      ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Dynatrace().applyUserPrivacyOptions(
      UserPrivacyOptions(DataCollectionLevel.User, true),
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserListWidget(),
      navigatorObservers: [
        DynatraceNavigationObserver(),
      ],
    );
  }
}

class Screen1 extends StatefulWidget {
  const Screen1({Key key}) : super(key: key);

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 1'),
      ),
      body: Center(
        child: RaisedButton(
            child: Text('Screen 1'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Screen2(),
                ),
              );
            }),
      ),
    );
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({Key key}) : super(key: key);

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen 2'),
      ),
      body: Center(
        child: RaisedButton(
            child: Text('Screen 2'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
    );
  }
}

class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Testing Dtnatrace'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: FutureBuilder<List<User>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final users = snapshot.data;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.email),
                        leading: Text(user.id.toString()),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Column(
            children: [
              RaisedButton(
                  child: Text('Screen 1'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Screen2(),
                      ),
                    );
                  }),
              RaisedButton(
                  child: Text('Reload'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        return UserListWidget();
                      }),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
