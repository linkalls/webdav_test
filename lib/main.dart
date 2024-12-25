import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webdav_client/webdav_client.dart';
import "package:webdav_test/gen/env.g.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SafeArea(child: MyHomePage()),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final client = newClient(
      'https://webdav.pcloud.com',
      user: Env.userName,
      password: Env.password,
      debug: true,
    );

    // Set the public request headers
    client.setHeaders({'accept-charset': 'utf-8'});

    // Set the connection server timeout time in milliseconds.
    client.setConnectTimeout(8000);

    // Set send data timeout time in milliseconds.
    client.setSendTimeout(8000);

    // Set transfer data time in milliseconds.
    client.setReceiveTimeout(8000);

    final list = useState([]);
    final fileRegExp = RegExp(r'\.(.)*');

    useEffect(() {
      Future<void> fetchData() async {
        list.value = await client.readDir('/');
        for (var f in list.value) {
          print(f.name);
        }
      }

      try {
        fetchData();
      } catch (e) {
        print(e);
        //* もっかいやる
        fetchData();
      } finally {
        print('finally');
      }

      return null;
    }, []);
    return Scaffold(
      body: Center(
          child: ListView.builder(
        itemCount: list.value.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: Column(
              children: [
                Text(list.value[index].name),
                Text(list.value[index].path),
                fileRegExp.hasMatch(list.value[index].name)
                    ? Text('Fileです')
                    : Text('Folderです'),
              ],
            )),
          );
        },
      )),
    );
  }
}
