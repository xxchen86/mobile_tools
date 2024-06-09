import 'package:flutter/material.dart';
import 'package:mobile_tools/diet_page.dart';
import 'package:mobile_tools/expiration_time_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '一刀999，是兄弟就来砍我',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
      routes: {
        '/expirationTimePage': (context) => ExpirationTimePage(),
        '/dietPage': (context) => DietPage(),
      },
    );
  }
}


class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/expirationTimePage');
              },
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  '食品过期时间计算器',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dietPage');
              },
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  '饮食页面',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}