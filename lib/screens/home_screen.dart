import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/apiHelper.dart';
import 'package:tronchatoro_app/helpers/constans.dart';
import 'package:tronchatoro_app/models/Foods.dart';
import 'package:tronchatoro_app/models/orderDetail.dart';
import 'package:tronchatoro_app/models/response.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:tronchatoro_app/screens/Orders_screen.dart';
import 'package:tronchatoro_app/screens/login_screen.dart';
import 'package:tronchatoro_app/screens/order_InputScreen.dart';
import 'package:tronchatoro_app/screens/user_screen.dart';
import 'package:tronchatoro_app/screens/users_Screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showLoader = false;
  late User _user;
  late List<Foods> _foods = [];
  CarouselController _carouselController = CarouselController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.token.user;
    _LoadData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Troncha-Toro'),
      ),
      body: _showLoader ? LoaderComponent(text: 'Por favor espere...',)
                        : Container(
                          color: Colors.black12,
                          child: RefreshIndicator(
                              onRefresh: _LoadData, 
                              child: _getBody()
                            ),
                        ),
      drawer: widget.token.user.rolId == 1
              ? _getMenuAdmin()
                : widget.token.user.rolId == 2
                ? _getMenuDomiciliary()
                  :  widget.token.user.rolId == 3
                  ? _getMenuUser()
                    : Container(),
    );
  }

  Widget _getBody() {
    return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: _user.imageFullPath,
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
                  Row(
                    children: <Widget>[
                      Text('Nombre: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.left,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-180,
                        child: Text(
                          _user.name+' '+ _user.lastName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-180,
                        child: Text(
                          _user.email,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                    Row(
                    children: <Widget>[
                      Text('Telefono: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-180,
                        child: Text(
                          _user.phoneNumber,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: <Widget>[
                      Text('Dirección: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-180,
                        child: Text(
                          _user.address, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                          ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40,),
          Text('Clic en la imagen para hacer tu pedido.', style: TextStyle(fontSize: 20),),
          SizedBox(height: 20,),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _foods.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
              CarouselSlider(
                  items: _foods.map((i) {
                    return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                      child: Builder(
                        builder: (BuildContext context){
                          return InkWell(
                            onTap: () => _goNewOrder(i),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  child:  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CachedNetworkImage(
                                      imageUrl: i.imageFullPath,
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                      fit: BoxFit.cover,
                                      height: 250,
                                      width: 300,
                                      placeholder: (context, url) => Image(
                                        image: AssetImage('assets/Tronchatoro.png'),
                                        fit: BoxFit.cover,
                                        height: 250,
                                        width: 300,
                                      ),
                                    ),
                                  )
                                ),
                                SizedBox(height: 20,),
                                Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(i.descriptionFood, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                                      ),
                                      SizedBox(height: 5,),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Precio: ${NumberFormat.currency(symbol: '\$',  decimalDigits: 0).format(i.priceFood)}', style: TextStyle(fontSize: 20,), textAlign: TextAlign.left),
                                      ),
                                      SizedBox(height: 5,),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(i.observations, style: TextStyle(fontSize: 20,), textAlign: TextAlign.left),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        }
                        ),
                    );
                  }).toList(), 
                  options: CarouselOptions(
                  height: 450,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }
                ),
              ),
            ],
          ),
        ],
      );
  }

  Widget _getMenuAdmin() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image:  AssetImage('assets/Tronchatoro.png'),
            ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Inicio', style: TextStyle(fontSize: 17),),
              onTap: (){
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token,)
                  )
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Usuarios', style: TextStyle(fontSize: 17),),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => UsersScreen(token: widget.token,)
                  )
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: const Text('Estado ordenes', style: TextStyle(fontSize: 17),),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(token: widget.token, userParam: widget.token.user, State: 2,)
                  )
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: const Text('Carrito compras', style: TextStyle(fontSize: 17),),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => OrdersScreen(token: widget.token, userParam: widget.token.user, State: 1,)
                  )
                );
              },
            ),
            Divider(
            color: Colors.black, 
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: const Text('Mis datos', style: TextStyle(fontSize: 17),),
            onTap: () {
              Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => UserScreen(token: widget.token, user: _user,)
                  )
                );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Cerras Sesión', style: TextStyle(fontSize: 17),),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  Widget _getMenuDomiciliary() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image:  AssetImage('assets/Tronchatoro.png'),
            ),
            ),
            ListTile(
              leading: Icon(Icons.delivery_dining),
              title: const Text('Entregar pedido', style: TextStyle(fontSize: 17),),
              onTap: (){},
            ),
        ],
      ),
    );
  }

  Widget _getMenuUser() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image:  AssetImage('assets/Tronchatoro.png'),
            ),
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: const Text('Mis pedidos', style: TextStyle(fontSize: 17),),
              onTap: (){},
            ),
        ],
      ),
    );
  }

  Future _getUser() async {
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

    Response response = await ApiHelper.getUser(widget.token);

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

  Future _LoadData() async {
    await _getFoods();
    await _getUser();
  }
  
  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

     Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => LoginScren()
        )
      );
  }

  Future _goNewOrder(Foods i) async {

    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => OrdersScreen(token: widget.token, userParam: widget.token.user, State: 1,)
      )
    );

  }
}
