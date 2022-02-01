import 'dart:ffi';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/apiHelper.dart';
import 'package:tronchatoro_app/models/Foods.dart';
import 'package:tronchatoro_app/models/order.dart';
import 'package:tronchatoro_app/models/orderDetail.dart';
import 'package:tronchatoro_app/models/response.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:tronchatoro_app/screens/order_InputScreen.dart';

class NewOrderScreen extends StatefulWidget {
  final Token token;
  final User user;

  const NewOrderScreen({required this.token, required this.user});

  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {

  bool _showLoader = false;
  List<Foods> _foods = [];

  @override
  void initState() {
    super.initState();
    _LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva orden'),
      ),
      body: Container(
        color: Colors.black12,
        child: Stack(
          children: <Widget>[
            _GetContent(),
            _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
          ],
        ),
      ),
    );
  }

  void _LoadData() async {
    await _getFoods();
  }

  Future _getFoods() async {
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

    Response response = await ApiHelper.getFoods(widget.token); 

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
      _foods = response.result;
    });
  }

  Widget _GetContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
      child: ListView(
        shrinkWrap: true,
        children: _foods.map((e) {
          return Card(
            elevation: 20,
            margin: EdgeInsets.only(top: 10),
            shadowColor: Colors.black,
            child: Container(
              padding: EdgeInsets.all(15),
              child: InkWell(
                onTap: () => _goDetailOrder(e),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10,),
                    _showPhoto(e),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _showPhoto(Foods _foodParam) {
    return Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: _foodParam.imageFullPath,
                      fit: BoxFit.cover, 
                      height: 150,
                      width: 280,            
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(_foodParam.descriptionFood, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  Container(
                    width: 298,
                    child: Text(_foodParam.observations, style: TextStyle(fontSize: 17),)
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 24,),
            ],
          );
  }

  void _goDetailOrder(Foods foodParam) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) =>
        OrderInputScreen(token: widget.token, 

        NewOrder: true, //widget.user.orders.length == 0 ? false : true,
        user: widget.user,

        orderDetails: new OrderDetails(idDetail: 0, idOrder: 0, idFood: 0, foods: [], 
        ordersDetailAdditions: [], Quantity: 0),
        
        foods: foodParam)
      )
    );

    if(result == 'yes'){
      Navigator.pop(context,'yes');
    }
  }
}