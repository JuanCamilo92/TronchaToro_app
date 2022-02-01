import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/apiHelper.dart';
import 'package:tronchatoro_app/models/response.dart';

import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:tronchatoro_app/screens/Orders_screen.dart';

class UsersScreen extends StatefulWidget {
  final Token token;

  UsersScreen({required this.token});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _user = [];
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getUsers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
      ),
      body: Center(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...',): _GetContent()
      ),
    );
  }

  Future _getUsers() async {
    setState(() {
      _showLoader = true;
    });

    var connerctivityResult = await Connectivity().checkConnectivity();
    if(connerctivityResult == ConnectivityResult.none){
        setState(() {
          _showLoader = false;
        });

        await showAlertDialog(
        context: context,
        title: 'Error',
        message: 'Verifica que estes conectado a internet',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }

    Response response = await ApiHelper.getUsers(widget.token); 

    setState(() {
      _showLoader = false;
    });

    if(!response.isSuccess)
    {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }

    setState(() {
      _user = response.result;
    });
    
  }

  Widget _GetContent() {
    return _user.length == 0
    ? _noContent()
    : _getListView();
  }

  Widget _noContent() {
  return Center(
    child: Container(
      margin: EdgeInsets.all(20),
      child: Text('No hay usuarios registrados',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      ),
    ),
  );
  }

  Widget _getListView() {
    return Container(
      color: Colors.black12,
      child: RefreshIndicator(
        onRefresh: _getUsers,
        child: ListView(
          children: _user.map((e) {
            return Card(
              child: InkWell(
                onTap: () => _goOrderInfo(e),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: e.imageFullPath,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                              placeholder: (context, url) => Image(
                                image: AssetImage('assets/Tronchatoro.png'),
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                                )
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            SizedBox(height: 10,),
                            Row(children:  <Widget>[
                              Text('Nombre: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                              SizedBox(
                                width: MediaQuery.of(context).size.width-180,
                                child: Text(
                                    e.name+' '+ e.lastName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            Row(children: <Widget>[
                              Text('N Ordenes: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width-200,
                                  child: Text(
                                    e.NOrders.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              ]
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  _goOrderInfo(User e) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => OrdersScreen(token: widget.token, userParam: e, State: 2,)
      )
    );
  }
}