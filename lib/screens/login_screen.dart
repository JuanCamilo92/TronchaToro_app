import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/constans.dart';
import 'package:http/http.dart' as http;
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:tronchatoro_app/screens/home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tronchatoro_app/screens/newUser_screen.dart';
import 'package:tronchatoro_app/screens/user_screen.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class LoginScren extends StatefulWidget {
  const LoginScren({ Key? key }) : super(key: key);

  @override
  _LoginScrenState createState() => _LoginScrenState();
}

class _LoginScrenState extends State<LoginScren> {

  bool _showLoader = false;

  String _email = '';
  bool _emailShowError = false;
  String _emailError = '';

  String _password = '';
  bool _passwordShowError = false;
  String _passwordError = '';
  bool _passwordShow = false;

  bool _rememberme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 40,),
                  _ShowLogo(),
                  _ShowUser(),
                  _ShowPassword(),
                  _ShowRememberme(),
                  _ShowButtons(),
                  _ShowButtonsNewUser(),
                  _showGoogleLoginButton(),
                  _showForgotPassword()
                ],
              ),
            ),
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],),
    );
  }

  Widget _ShowLogo() {
    return Image(
      image: AssetImage('assets/Tronchatoro.png'),
      width: 300,
      fit: BoxFit.fill,
    );
  }

  Widget _ShowUser() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Ingresa tu Email...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
        ),
        onChanged: (value){
          _email = value;
        },
      ),
    );
  }

  Widget _ShowPassword() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Ingresa tu contraseña...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.lock),
          errorText: _passwordShowError ? _passwordError : null,
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility_off) : Icon(Icons.lock),
            onPressed: (){
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
        ),
        onChanged: (value){
          _password = value;
        },
      ),
    );
  }

  Widget _ShowButtons() {
   return Container(
     margin: EdgeInsets.only(left: 10, right: 10),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceAround,
       children: <Widget>[
         Expanded(
           child: ElevatedButton(
            child: Text('Iniciar sesión'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states){
                  return Color(0xFF120E43);
                }
              ),
            ),
            onPressed: () => _Login(),
           ),
         ),
       ],
     ),
   );
 }

  Widget _ShowRememberme() {
   return CheckboxListTile(
     title: Text('Recordarme'),
     value: _rememberme,
     onChanged: (value){
       setState(() {
         _rememberme = value!;
       });
     },
   );
 }

  Widget _showForgotPassword() {
   return Container(
     padding: EdgeInsets.all(10),
     child: InkWell(
       onTap: (){},
       child: Container(
         margin: EdgeInsets.only(bottom: 20),
         child: Text('¿Has olvidado tu contraseña?',
         style: TextStyle(color: Colors.blue, fontSize: 17),),
       ),
     ),
   );
 }

  Widget _showGoogleLoginButton() {
   return Container(
     margin: EdgeInsets.only(left: 10, right: 10),
     child: Row(
       children: <Widget>[
         Expanded(
           child: ElevatedButton.icon(
             onPressed: ()=> _loginGoogle(), 
             icon: FaIcon(
               FontAwesomeIcons.google,
               color: Colors.red,
             ),
             label: Text('Registrate o iniciar sesión con Google'),
             style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black
              )
             ),
         ),
       ],
     ),
   );
 }

  Widget _ShowButtonsNewUser() {
   return Container(
     padding: EdgeInsets.only(left: 10, right: 10),
     child: Row(
       children: <Widget>[
         Expanded(
           child: ElevatedButton(
             child: Text('Registrate'),
             style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states){
                    return Color(0xFF120E43);
                  }
                ),
             ),
             onPressed: (){
               Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => NewUserScreen()
                  )
                );
             },
           ),
         ),
       ],
     ),
   );
 }

  void _Login() async {
   setState(() {
     _passwordShow = false;
   });

   if(!_validateFields()){
     return;
   }

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

    Map<String, dynamic> request = {
      "email": _email,
      "contraseña": _password
    };

    var url = Uri.parse('${Constans.apiUrl}/api/User/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: jsonEncode(request)
    );

    setState(() {
      _showLoader = false;
    });

    if(response.statusCode >= 400){  
      setState(() {
        _passwordShowError = true;
        _passwordError = response.body != null ? response.body : 'Usuario o contraseña incorrectos';
      });
      return;
    }

    var body = response.body;

    if(_rememberme){
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(token : token) //token: token,
      )
    );
 }

  void _loginGoogle() async {
    setState(() {
      _showLoader = true;
    });

    var googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    var user = await googleSignIn.signIn();

    if (user == null) {
      setState(() {
        _showLoader = false;
      });
 
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: 'Hubo un problema al obtener el usuario de Google, por favor intenta más tarde.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Map<String, dynamic> request = {
      'email': user.email,
      'Rol_id' : 1,
      'Name': user.displayName,
      'BirthDate' : '2000-01-01',
      'imageId': user.photoUrl,
      'LoginType': "1",
    };

    await _socialLogin(request);
  }

  Future _socialLogin(Map<String, dynamic> request) async {
    var url = Uri.parse('${Constans.apiUrl}/api/User/SocialLogin');
    var bodyRequest = jsonEncode(request);
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: bodyRequest,
    );

    setState(() {
      _showLoader = false;
    });

    if(response.statusCode >= 400) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'El usuario ya inció sesión previamente por email o por otra red social.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    var body = response.body;

    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => HomeScreen(token: token,)
      )
    );
  }

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }

  bool _validateFields() {
    bool isValid = true;

    if(_email.isEmpty){
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email';
    }
    else if(!EmailValidator.validate(_email)){
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email valido';
    }
    else {
      _emailShowError = false;
    }

    if(_password.isEmpty){
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar una contraseña';
    }
    else{
      _passwordShowError = false;
    }

    setState(() {});

    return isValid;
  }

}