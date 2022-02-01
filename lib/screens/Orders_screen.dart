import 'dart:ffi';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:darq/src/extensions/select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/retry.dart';
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
import 'package:tronchatoro_app/screens/newOrder_screen.dart';
import 'package:tronchatoro_app/screens/order_InputScreen.dart';

class OrdersScreen extends StatefulWidget {
  final Token token;
  final User userParam;
  final int State;

  OrdersScreen({required this.token, required this.userParam, required this.State});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late User _user;
  bool _showLoader = false;
  int _Total = 0;
  bool _Accept = false;
  bool _ActiveButton = false;

  @override
  void initState() {
    super.initState();
    _LoadScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.State == 2 ? 'Orden' : 'Carrito compras'}'),
      ),
      body: Container(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...',): _GetContent()
      ),
      bottomNavigationBar:
      widget.State == 2 
      ? SizedBox()
      : Container(
        padding: EdgeInsets.all(5),
        color: Colors.yellow[200],
        child: SizedBox(
          height: 105,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width-20,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text('Acepto haber leido los terminos y condiciones y la politica de privacidad para hacer esta compra',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14)),
                      value: _Accept,
                      onChanged: (value){
                        setState(() {
                          _Accept = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      //_ActiveButton
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.gpp_good),
                        SizedBox(width: 30,),
                        Text('Pagar total', style: TextStyle(fontSize: 18),),
                        ],
                      ),
                      style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states){
                          return Color(0xFF120E43);
                          }
                        ),
                      ),
                      onPressed: () => _Accept ? _PayMethod() : _Message('Por favor acepte que leyo los terminos y condiciones para poder continuar con la compra'),
                    ),
                ),
                SizedBox(width: 80,),
                Text('${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(_Total)}', 
                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                     textAlign: TextAlign.right,),
                ],
              ),
            ],
          ),
          ),
      ),
      floatingActionButton: widget.State != 2 
        ? FloatingActionButton.extended(
          onPressed: () =>  _goAddOrder(),
          label: const Text('Orden'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.black87,
          elevation: 0,
          ) 
        : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future _LoadScreen() async{
  await _getOrderInfo();
  await _getTotalCompete();
  //await _getTotalCompete();
}

  Future _getOrderInfo() async {
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

    Response response = await ApiHelper.GetOrdersInfo(widget.token, widget.userParam, widget.State); 

    setState(() {
          _showLoader = false;
    });

    if(!response.isSuccess){
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          // ignore: prefer_const_constructors
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
    return _user.orders.length <= 0
    ? _noContent()
    : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text('No tiene ordenes, por favor agregar una orden...',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return 
        RefreshIndicator(
        onRefresh: () => _LoadScreen(),
        child: _ListViewOrders(),
      );
  }

  Widget _ListViewOrders() {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.all(5),
      child: ListView(
        shrinkWrap: true,
        children: _user.orders.map((e) {
          return Card(
            elevation: 20,
            //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(top: 20),
            child: Column(
                children: <Widget>[
                  Center(
                    child: Text('Estado: ${e.IdStatePay == 2 ? e.StateTran : e.StatePay}', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                      color: e.IdStateTran == 4 ? Colors.orange[400] : Colors.red[400] 
                    )),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10,),
                      Text('N. Orden: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-260,
                        child: Text(
                          e.nOrder.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20)
                        ),
                      ),
                      Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      Text('${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(e.Total)}', 
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.right,),
                    ],
                  ),
                  e.orderDetails.length > 0 ? _ListViewDetailOrders(e.orderDetails) : Container(),
                ],
              ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ListViewDetailOrders(List<OrderDetails> orderDetails){
    return Column(
      children: <Widget>[
        SizedBox(height: 10,),
        Row(
          children: <Widget>[
            Text('Detalle de la orden: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),),
          ],
        ),
        ListView(
        physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: orderDetails.map((e) {
            return ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: e.foods.map((f) {
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 5,),
                          Row(
                            children: <Widget>[
                              CachedNetworkImage(
                                  imageUrl: f.imageFullPath,
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
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  children: <Widget>[
                                    Text('${f.descriptionFood} x ${e.Quantity}', style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 18),),
                                    SizedBox(height: 5,),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width-200,
                                      child: Text(
                                          f.observations,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                  ],
                                )
                              ),
                              Column(
                                children: <Widget>[
                                  Text('${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(f.priceFood * e.Quantity)}', 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Center(
                              child: Text('Adiciones: ', style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16)),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width-50,
                            child: e.ordersDetailAdditions.length > 0 
                              ? _ListViewDetailAdditions(e.ordersDetailAdditions) 
                              : Center(child: Text('No tiene adiciones', style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16)),),
                          ),
                        ],
                      ),
                      widget.State == 2
                      ? SizedBox()
                      : Positioned(
                        bottom: 40,
                        left: 0,
                        child: InkWell(
                          onTap: () => _goEditOrders(e,_user, f),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Colors.green[50],
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.edit,
                                size: 30,
                                color: Colors.blue,
                                ),
                            ),
                            ),
                        ),
                      ),
                      widget.State == 2
                      ? SizedBox()
                      : Positioned(
                        bottom: 40,
                        left: 60,
                        child: InkWell(
                          onTap: () async {

                            String response = await showAlertDialog(
                              context: context,
                              title: 'Confirmación',
                              message: "¿Esta seguro(a) de borrar ${f.descriptionFood} x ${e.Quantity}?",
                              actions: <AlertDialogAction>[
                                AlertDialogAction(key: 'no', label: 'Cancelar'),
                                AlertDialogAction(key: 'yes', label: 'Borrar'),
                              ]
                            );
                            response == 'yes' ? _goDeleteOrderDtl(e.idDetail.toString()) : null;

                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Colors.green[50],
                              height: 40,
                              width: 40,
                              child: Icon(
                                Icons.delete,
                                size: 30,
                                color: Colors.red,
                                ),
                            ),
                            ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
            );
          }).toList()
        ),
      ],
    );
  }

  Widget _ListViewDetailAdditions(List<OrdersDetailAdditions> ordersDetailAdditions){
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: ordersDetailAdditions.map((e) {
        return ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: e.additions.map((a) {
            return Row(
              children: <Widget>[
                    Expanded(
                      child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width-270,
                              child: Text(
                                  a.descriptionAddition.toString() + ' x ' + e.Quantity.toString(),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                        ),
                    ),
                    Column(
                      children: <Widget>[
                        Text('${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(a.priceAddition*e.Quantity)}', 
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      ],
                    ),
              ],
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Future _goAddOrder() async {
    
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => NewOrderScreen(token: widget.token, user: _user,)
      )
    );

    if(result == 'yes'){
      _LoadScreen();
    }
  }

  void _PayMethod() async {
    
  }

  Future _getTotalCompete() async {
    
    int totalMoney = 0;

    for (var item in _user.orders) {
     totalMoney += item.Total;
    }

    setState(() {
      _Total = totalMoney;
    });
  }

  void _goEditOrders(OrderDetails orderDetail, User user, Foods foods) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => 
        OrderInputScreen(token: widget.token, NewOrder: false, user: _user, orderDetails: orderDetail, foods: foods,)
      )
    );

    if(result == 'yes'){
      _LoadScreen();
    }
  }

  void _Message(String Menssage) async {
    await showAlertDialog(
        context: context,
        title: 'Alerta',
        message: Menssage,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar',),
        ]
      );
  }

  Future _goDeleteOrderDtl(String Id) async {
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

    //API
    Response response = await ApiHelper.deletePost(
        '/api/User/DeleteOrderDtl/',
        Id, 
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

    _LoadScreen();
    
  }

  
  //PENDIENTE ESTADO DE PEDIDO
}