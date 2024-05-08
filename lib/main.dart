import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    const MainPage(),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DJS',
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: "https://1408bg.github.io/nav",
        onWebViewCreated: (controller){
          _webViewController = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) async {
          try {
            var javascript = '''
                             window.alert = function (e){
                               Alert.postMessage(e);
                             }
                           ''';
            await _webViewController?.runJavascript(javascript);
          } catch (_) {}
        },
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
            name: 'Alert',
            onMessageReceived: (JavascriptMessage message) {
              showDialog(context: context, builder: (context){
                return Dialog(
                  child: SizedBox(
                    width: 200,
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("알림", style: TextStyle(fontSize: 24),),
                        Center(
                            child: Text(message.message, style: const TextStyle(fontSize: 18),)
                        )
                      ],
                    )
                  )
                );
              });
            }
        )
        },
      ),
    );
  }
}