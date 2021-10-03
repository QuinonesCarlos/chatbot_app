import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/cliente_provider.dart';
import '../sistema.dart';
import 'shared_preferences.dart';

const String _PUSH_OBJECT = '100';

class PushProvider {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late BuildContext context;

  static PushProvider? _instancia;

  PushProvider._internal();

  factory PushProvider() {
    if (_instancia == null) {
      _instancia = PushProvider._internal();
      _instancia!.initNotifications();
    }
    return _instancia!;
  }

  final PreferenciasUsuario prefs = PreferenciasUsuario();

  final ClienteProvider _clienteProvider = ClienteProvider();

  final StreamController<Object> _objectStreamController =
      StreamController<Object>.broadcast();

  Stream<Object> get objects => _objectStreamController.stream;

  obtenerToken() async {
    _firebaseMessaging.requestPermission(alert: true, sound: true, badge: true);
    String? nuevoToken = await _firebaseMessaging.getToken();
    if (nuevoToken.toString() == prefs.token.toString()) return;
    prefs.token = nuevoToken;
    if (prefs.idCliente == '') {
      return;
    }
    _clienteProvider.actualizarToken().then((isActualizo) {
      prefs.empezamos = isActualizo;
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future _showNotification(RemoteNotification? push) async {
    if (push == null || push.title == null || push.body == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'CHECK_CHANNEL_ID', 'Check Notification', 'Check',
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: 'Check_GROUP_KEY',
            autoCancel: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        1682, push.title, push.body, platformChannelSpecifics);
  }

  cancelAll() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
      ),
    );
  }

  initNotifications() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    obtenerToken();
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
  }

  Future _onMessageHandler(RemoteMessage message) async {
    if (Sistema.isAndroid) {
      if (message.data['PUSH'] == _PUSH_OBJECT) {
        procesarObject(message.data, message.notification);
      }
    } else {
      if (message.data['PUSH'] == _PUSH_OBJECT) {
        procesarObject(message.data, message.notification);
      }
    }
  }

  Future _onMessageOpenApp(RemoteMessage message) async {
    var push = message.data;
    if (Sistema.isAndroid) {
      if (message.data['PUSH'] == _PUSH_OBJECT) {}
    } else {
      if (push['PUSH'] == _PUSH_OBJECT) {}
    }
  }

  procesarObject(push, RemoteNotification? notification) {
    if (push['tipo'] == '1') {
      _showNotification(notification);
      String chat = push['chat'].toString();
      _objectStreamController.sink.add(chat);
    }
  }

  dispose() {
    _objectStreamController.close();
  }
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PreferenciasUsuario().init();
  if (message.data['PUSH'] == _PUSH_OBJECT) {
    // final string = json.decode(message.data['chat']);
  }
  PushProvider()._showNotification(message.notification);
}
