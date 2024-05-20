import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async{
  await start();
  runApp(const Entry());
}

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Launch(),
    );
  }
}


class Launch extends StatefulWidget {
  const Launch({super.key});

  @override
  State<Launch> createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  final TextEditingController _grade = TextEditingController();
  final TextEditingController _class = TextEditingController();
  late final SharedPreferences _pref;

  @override
  void initState(){
    super.initState();
    initPreferences();
  }

  Future<void> initPreferences() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.getBool('inputed') == null){
      await _pref.setBool('inputed', false);
    }
    if (_pref.getBool('inputed') == true){
      _next();
    }
  }

  void _next(){
    if (_pref.getBool('inputed')!){
      _navigate();
      return;
    }
    if (_grade.text.isEmpty || _class.text.isEmpty || int.parse(_grade.text) > 3 || int.parse(_class.text) > 4 || (int.parse(_grade.text) + int.parse(_class.text)) < 2){
      showDialog(
        context: context,
        builder: (context){
          return const Dialog(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Center(
                child: Text("유효한 값을 입력하세요", style: TextStyle(fontSize: 24))
              )
            )
          );
        }
      );
      return;
    }
    _pref.setBool("inputed", true);
    _pref.setInt("grade", int.parse(_grade.text));
    _pref.setInt("class", int.parse(_class.text));
    _navigate();
  }

  void _navigate(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage())
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("First Launch Screen"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Input Your Info", style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _grade,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                        hintText: "grand"
                    )
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _class,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                        hintText: "class"
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 40),
            IconButton(
                onPressed: _next,
                icon: const Icon(Icons.send)
            )
          ],
        ),
      ),
    );
  }
}
