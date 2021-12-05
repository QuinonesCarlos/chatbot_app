import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../sistema.dart';
import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;

class AboutPage extends StatefulWidget {
  AboutPage() : super();

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  _AboutPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Acerca de')),
      body:
          Center(child: Container(child: _body(), width: prs.anchoFormulario)),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.confirmar('Contacto', () {
          _launchURL('https://ticosolutionsofficialdgo.000webhostapp.com/#contacto');
        }),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 35.0),
              Image(
                  image: AssetImage('assets/chatbot.png'),
                  width: 220.0,
                  fit: BoxFit.cover),
              SizedBox(height: 40.0),
              // Text('${Sistema.aplicativoTitle}', textAlign: TextAlign.center),
              SizedBox(height: 20.0),
              Text('', textAlign: TextAlign.center),
              SizedBox(height: 20.0),
              btn.booton('Política de privacidad', _politicas),
              btn.booton('Términos y condiciones', _terminos),
              SizedBox(height: 80.0),
            ],
          ),
        ),
      ],
    );
  }

  _politicas() {
    _launchURL('https://drive.google.com/file/d/1GWniM8k4lKOj9CN74-kYfUucY5xOa1Tm/view?usp=sharing');
  }

  _terminos() {
    _launchURL('https://drive.google.com/file/d/1yq_NKj1EV53UeNLBdTCdFkCSM2v4zRld/view?usp=sharing');
  }

  _launchURL(url) async {
    var encoded = Uri.encodeFull(url);
    if (await canLaunch(encoded)) {
      await launch(encoded);
    } else {
      print('Could not open the url.');
    }
  }
}
