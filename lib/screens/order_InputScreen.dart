//MIN 14:50 VIDEO 105 → PREPARAR LA APP PARA PUBLICAR EN PLAY STORE
import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/apiHelper.dart';
import 'package:tronchatoro_app/models/Foods.dart';
import 'package:tronchatoro_app/models/additions.dart';
import 'package:tronchatoro_app/models/order.dart';
import 'package:tronchatoro_app/models/orderDetail.dart';
import 'package:tronchatoro_app/models/ordersDetailAddition.dart';
import 'package:tronchatoro_app/models/response.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:darq/darq.dart';

class OrderInputScreen extends StatefulWidget {
  final Token token;
  final bool NewOrder;
  final OrderDetails orderDetails;
  final Foods foods;
  final User user;

  const OrderInputScreen({required this.token, required this.NewOrder, required this.orderDetails, required this.foods, required this.user});

  @override
  _OrderInputScreenState createState() => _OrderInputScreenState();
}

class _OrderInputScreenState extends State<OrderInputScreen> {

  bool _showLoader = false;
  String _Quantity = '0';
  int _additionId = 0;
  int _additionId2 = 0;
  String _QuantityAdd1 = '0';
  String _QuantityAdd2 = '0';
  int _idOrderDetailAddition1 = 0;
  int _idOrderDetailAddition2 = 0;

  List<Additions> _addition = [];
  TextEditingController _QuantityController = TextEditingController();
  TextEditingController _QuantityAdd1Controller = TextEditingController();
  TextEditingController _QuantityAdd2Controller = TextEditingController();
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.NewOrder ? 'Nueva orden' : 'Editar orden'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goCarPay(),
        label: const Text('Ir Carrito'),
        icon: const Icon(Icons.shopping_cart_outlined),
        backgroundColor: Colors.black87,
        elevation: 0,
        
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _GetContent() {
   return SingleChildScrollView(
     child: Container(
       padding: EdgeInsets.all(15),
       child:  Column(
           children: <Widget>[
            _showPhoto(),
            _showDataPhoto(),
            _showQuantity(),
             SizedBox(height: 10,),
            _showAdditions(),
            _showButton()
           ],
        ),
     ),
   );
 }

  void _LoadData() async {
    await _getAdditions();
    _LoadFields();
  }

  void _LoadFields(){
    _Quantity = widget.orderDetails.Quantity == 0 ? '1' : widget.orderDetails.Quantity.toString();
    _QuantityController.text = _Quantity.toString();

    int index = 0;
    for (var e in widget.orderDetails.ordersDetailAdditions) {
        index++;
        if(widget.orderDetails.ordersDetailAdditions.length != 0){
          if(widget.orderDetails.ordersDetailAdditions.length == 1){
            _additionId = e.idAddition;
            _additionId2 = 0;
            _QuantityAdd1 = e.Quantity.toString();
            _QuantityAdd1Controller.text = _QuantityAdd1.toString();
            _QuantityAdd2 = '0';
            _idOrderDetailAddition1 = e.idOrderDetailAddition;
          }else{
            if(index == 1){
              _additionId = e.idAddition;
              _QuantityAdd1 = e.Quantity.toString();
              _QuantityAdd1Controller.text = _QuantityAdd1.toString();
              _idOrderDetailAddition1 = e.idOrderDetailAddition;
            }else{
              _additionId2 = e.idAddition;
              _QuantityAdd2 = e.Quantity.toString();
              _QuantityAdd2Controller.text = _QuantityAdd2.toString();
              _idOrderDetailAddition2 = e.idOrderDetailAddition;
            }
          }
       }
    }
  }

  Widget _showQuantity() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: TextField(
        controller: _QuantityController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Cantidad',
          hintText: '¿Cuantas quieres?',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          //errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.tag),
          //suffixIcon: Icon(Icons.email),
        ),
        onChanged: (value){
          _Quantity = value == '' ? '0' : value;
        },
        style: TextStyle(height: 0.5),
      ),
    );
  }

  Widget _showAdditions() {
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _additon(_additionId, 1),
              Text('X'),
              Container(width: 60, 
              child: TextField(
                 textAlign: TextAlign.center,
                  controller: _QuantityAdd1Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    //labelText: 'Cantidad',
                    //hintText: '¿Cuantas quieres?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //errorText: _emailShowError ? _emailError : null,
                    //suffixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value){
                    _QuantityAdd1 = value == '' ? '0' : value;
                  },
                  style: TextStyle(height: 0.5, ),
                ),
              ),
              IconButton(
                onPressed: (){
                  setState(() {
                    _additionId = 0;
                    _QuantityAdd1 = '0';
                    _QuantityAdd1Controller.text = '0';
                  });
                }, 
                icon: Icon(Icons.clear),
                color: Colors.red,
              ),
            ],
          ),
          SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _additon(_additionId2, 2),
            Text('X'),
            Container(
              width: 60, 
              child: TextField(
              textAlign: TextAlign.center,
                controller: _QuantityAdd2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  //labelText: 'Cantidad',
                  //hintText: '¿Cuantas quieres?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //errorText: _emailShowError ? _emailError : null,
                  //suffixIcon: Icon(Icons.email),
                ),
                onChanged: (value){
                  _QuantityAdd2 = value == '' ? '0' : value;
                },
                style: TextStyle(height: 0.5),
              ),
            ),
            IconButton(
                onPressed: (){
                  setState(() {
                    _additionId2 = 0;
                    _QuantityAdd2 = '0';
                    _QuantityAdd2Controller.text = '0';
                  });
                }, 
                icon: Icon(Icons.clear),
                color: Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _getComboAdditions() {
    List<DropdownMenuItem<int>> list = [];
    list.add(DropdownMenuItem(
      child: Text('SIN ADICIÓN'),
      value: 0,
    ));

    _addition.forEach((addition) {
      list.add(DropdownMenuItem(
      child: Text('${addition.descriptionAddition} → ${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(addition.priceAddition)}'),
      value: addition.idAddition
      ));
    });

    return list;
  }

  Future _getAdditions() async {
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

    Response response  = await ApiHelper.getAdditions(widget.token);
    
    setState(() {
      _showLoader = false;
    });

    if(!response.isSuccess){
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
      _addition = response.result;
    });
 }

  Widget _showButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: ElevatedButton(
        //_ActiveButton
        child: Row(
        children: <Widget>[
          Icon(Icons.add_shopping_cart),
          SizedBox(width: 30,),
          Text(widget.NewOrder ? 'Agregar al carrito' : 'Modificar y agregar al carrito', style: TextStyle(fontSize: 18),),
          ],
        ),
        style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states){
            return Color(0xFF120E43);
            }
          ),
        ),
        onPressed: () => _AddToCar(),
      ),
    );
  }

  void _goCarPay() async {
    //Redirect
    Navigator.pop(context,'yes');
  }

  Widget _showPhoto() {
    return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.foods.imageFullPath,
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              height: 200,
              width: 300,
              placeholder: (context, url) => Image(
                image: AssetImage('assets/Tronchatoro.png'),
                fit: BoxFit.cover,
                height: 200,
                width: 300,
              ),
            ),
          );
  }

  Widget _showDataPhoto() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20,),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.foods.descriptionFood, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
        ),
        SizedBox(height: 5,),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Precio: ${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(widget.foods.priceFood)}', style: TextStyle(fontSize: 15,), textAlign: TextAlign.left),
        ),
        SizedBox(height: 5,),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.foods.observations, style: TextStyle(fontSize: 15,), textAlign: TextAlign.left),
        ),
      ],
    );
  }

  Widget _additon(int additionId, int pos) {
    return Container(
      width: 230,
      child: _addition.length == 0 
      ? Text('Cargando las adiciones...')
      : DropdownButtonFormField(
        autofocus: false,
        items: _getComboAdditions(),
        value: additionId,
        onChanged: (option){
          setState(() {
            pos == 1 ? _additionId = option as int : _additionId2 = option as int;
            if(pos == 1){
              if(option == 0){
                _QuantityAdd1 = '0';
              }
              else{
                _QuantityAdd1 = '1';
              }
              _QuantityAdd1Controller.text = _QuantityAdd1.toString();
            }
            else{
              if(option == 0){
                _QuantityAdd2 = '1';
              }
              else{
                _QuantityAdd2 = '1';
              }
              _QuantityAdd2Controller.text = _QuantityAdd2.toString();
            }
          });
        },
        decoration: InputDecoration(
          //hintText: 'Sin adición',
          labelText: 'Adición',
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        )
        ),
      ),
    );
  }

  void _AddToCar() {
    if(!_ValidateFields()){
      return;
    }

    widget.NewOrder ? _addOrder() : _updateOrder();
  }

  bool _ValidateFields() {

    if(_Quantity == '0'){
      _Message('Por favor digita la cantidad que quieres de '+ widget.foods.descriptionFood);
      return false;
    }
    if(!_ValidateDate(_Quantity)){
      _Message('Por favor digita una cantidad valida');
      return false;
    }
    if(_additionId != 0){
      if(!_ValidateDate(_QuantityAdd1)){
        _Message('Por favor digita una cantidad valida para la adición 1');
        return false;
      }
    }
    if(_additionId2 != 0){
      if(!_ValidateDate(_QuantityAdd2)){
        _Message('Por favor digita una cantidad valida para la adición 2');
        return false;
      }
    }
    return true;
  }
  
  void _Message(String Menssage) async {
    await showAlertDialog(
        context: context,
        title: 'Alerta',
        message: Menssage,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
  }

  Future _updateOrder() async {
    //loader
    setState(() {
      _showLoader = true;
    });

    //conexion a internet
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

    //maping
    List<Map<String, dynamic>> OrderDetailAdditions = [];

    //if(_additionId != 0){
      Map<String, dynamic> additions1 = {
        'Id': _idOrderDetailAddition1,
        'description': '',
        'price': 0,
        'IdAddition':_additionId,
        'Quantity':_QuantityAdd1,
        'IdDetailOrder':widget.orderDetails.idDetail
      };
      OrderDetailAdditions.add(additions1);
    //}

    //if(_additionId2 != 0){
      Map<String, dynamic> additions2 = {
        'Id': _idOrderDetailAddition2,
        'description': '',
        'price': 0,
        'IdAddition':_additionId2,
        'Quantity':_QuantityAdd2,
        'IdDetailOrder':widget.orderDetails.idDetail
      };
      OrderDetailAdditions.add(additions2);
    //}
    
    Map<String, dynamic> OrderDetails = new Map<String, dynamic>();
    OrderDetails['Id'] = widget.orderDetails.idDetail;
    OrderDetails['Quantity'] = _Quantity;
    OrderDetails['OrderDetailAdditions'] = OrderDetailAdditions;

    //API
    Response response = await ApiHelper.post(
        '/api/User/UpdateOrder/',
        OrderDetails, 
        widget.token
      );

    //loader
    setState(() {
      _showLoader = false;
    });

    //Validacion response
    if(!response.isSuccess){
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

    //Redirect
    Navigator.pop(context,'yes');
  }

  Future _addOrder() async {

     setState(() {
      _showLoader = true;
    });

    //conexion a internet
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
    
    List<Map<String, dynamic>> OrderDetailAdditions = [];

    Map<String, dynamic> additions1 = {
      'Id': _idOrderDetailAddition1,
      'description': '',
      'price': 0,
      'IdAddition':_additionId,
      'Quantity':_QuantityAdd1,
      'IdDetailOrder':widget.orderDetails.idDetail
    };
    OrderDetailAdditions.add(additions1);

    Map<String, dynamic> additions2 = {
      'Id': _idOrderDetailAddition2,
      'description': '',
      'price': 0,
      'IdAddition':_additionId2,
      'Quantity':_QuantityAdd2,
      'IdDetailOrder':widget.orderDetails.idDetail
    };
    OrderDetailAdditions.add(additions2);
    
    Map<String, dynamic> OrderDetails = new Map<String, dynamic>();
    OrderDetails['Id'] = widget.orderDetails.idDetail;

    OrderDetails['IdOrder'] = widget.NewOrder && widget.user.orders.length == 0 
                              ? 0
                              : widget.user.orders.map((e) => e.orderDetails.map((e) => e.idOrder).first).first;
    OrderDetails['IdFood'] = widget.foods.idFood;

    OrderDetails['Quantity'] = _Quantity;
    OrderDetails['OrderDetailAdditions'] = OrderDetailAdditions;

    Map<String, dynamic> request = {
      'FullName' : widget.NewOrder && widget.user.orders.length == 0 ? '${widget.user.name} ${widget.user.lastName}' : '',
      'IdUser': widget.user.email,
      'Address': widget.user.address,
      'PhoneNumber': widget.user.address,
      'IdStateTran': 3,
      'IdStatePay': 1,
      'orderDetails': OrderDetails,
    };

    //API
    Response response = await ApiHelper.post(
        '/api/User/AddOrder/',
        request, 
        widget.token
      );

    //loader
    setState(() {
      _showLoader = false;
    });

    //Validacion response
    if(!response.isSuccess){
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

    //Redirect
    Navigator.pop(context,'yes');
  }

  bool _ValidateDate(String Value) {
    try{
        int.parse(Value);
        return true;
    }
    on Exception catch(e){
      return false;
    }
  }
}