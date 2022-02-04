import 'package:flutter/material.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';

class UserScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserScreen({required this.token, required this.user});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar usuario'),
      ),
      body: Container(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...',): _GetContent(),
      ),
    );
  }

  Widget _GetContent() {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          _showPhoto(),
          _showEmail(),
          _showName(),
          _showLastName(),
          _showBirtDate(),
          _showAddress(),
          _showPhoneNumber(),
          _showButtons(),
        ],
      ),
    );
  }

  Widget _showPhoto() {
    return Container(
    );
  }

  Widget _showButtons() {
    return Container(

    );
  }

  Widget _showEmail() {
    return Container(

    );
  }

  Widget _showName() {
    return Container(

    );
  }

  Widget _showLastName() {
    return Container(

    );
  }

  Widget _showBirtDate() {
    return Container(

    );
  }

  Widget _showAddress() {
    return Container(

    );
  }

  Widget _showPhoneNumber() {
    return Container(

    );
  }
}