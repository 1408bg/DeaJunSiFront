import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notifications = FlutterLocalNotificationsPlugin();

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCR7Wo3aMdP7Sr6403cUJgllQSSWOAlUw8",
        appId: "1:828670110990:android:70590fa058deccae2cfb5f",
        messagingSenderId: "828670110990",
        projectId: "djs-app-50ef7",
      )
  );
  FirebaseMessaging.instance.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );
  notifications.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
          iOS: IOSInitializationSettings(
              requestAlertPermission: true,
              requestBadgePermission: true,
              requestSoundPermission: true
          ),
          linux: LinuxInitializationSettings(
            defaultActionName: "djs",
          )
      )
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
  late final SharedPreferences _pref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initPreferences() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse("https://daejeonsi.nanu.cc/"))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    initPreferences();
    super.initState();
    start();
    _firebaseMessaging.getToken().then((token) {
      http.get(
        Uri.parse("https://daejeonsi.nanu.cc/api/${_pref.getInt('grade')}${_pref.getInt('class')}$token")
      );
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.body.toString()),
            duration: const Duration(seconds: 2),
          )
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      notifications.show(
          1,
          'DJS',
          message!.notification!.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                'DJS',
                'DJS',
                priority: Priority.high,
                importance: Importance.max,
                color: Color.fromARGB(255, 255, 0, 0),
              ),
              iOS: IOSNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true
              ),
              linux: LinuxNotificationDetails()
          )
      );
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      notifications.show(
          1,
          'DJS',
          message?.notification!.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                'DJS',
                'DJS',
                priority: Priority.high,
                importance: Importance.max,
                color: Color.fromARGB(255, 255, 0, 0),
              ),
              iOS: IOSNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true
              ),
              linux: LinuxNotificationDetails()
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: WebViewWidget(controller: _webViewController!)
    );
  }
}