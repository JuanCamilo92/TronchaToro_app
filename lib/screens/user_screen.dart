import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/helpers/apiHelper%20copy.dart';
import 'package:tronchatoro_app/helpers/constans.dart';
import 'package:tronchatoro_app/models/response.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';
import 'package:tronchatoro_app/screens/home_screen.dart';
import 'package:tronchatoro_app/screens/take_picture_screen.dart';
import 'package:http/http.dart' as http;

class UserScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserScreen({required this.token, required this.user});//, required this.user

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showLoader = false;
  late XFile _image;
  bool _photoChanged = false;
  String _NameImage = '';

  String _Email = '';
  String _EmailError = '';
  bool _showEmailError = false;
  TextEditingController _EmailController = TextEditingController();

  String _Name = '';
  String _NameError = '';
  bool _showNameError = false;
  TextEditingController _NameController = TextEditingController();

  String _LastName = '';
  String _LastNameError = '';
  bool _showLastNameError = false;
  TextEditingController _LastNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _BirtDateError = '';
  bool _showBirtDateError = false;
  TextEditingController _BirtDateController = TextEditingController();

  String _Address = '';
  String _AddressError = '';
  bool _showAddressError = false;
  TextEditingController _AddressController = TextEditingController();

  String _PhoneNumber = '';
  String _PhoneNumberError = '';
  bool _showPhoneNumberError = false;
  TextEditingController _PhoneNumberController = TextEditingController();

@override
  void initState() {
    _LoadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar usuario') ,
      ),
      body: Container(
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...',): _GetContent(),
      ),
    );
  }


  Widget _GetContent() {
    return Container(
      //color: Colors.black26,
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _showPhoto(),
            _showEmail(),
            _showName(),
            _showLastName(),
            _showBirtDate(),
            _showAddress(),
            _showPhoneNumber(),
            widget.token.user.LoginType != '1' ? _showButtons() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _showPhoto() {
   return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10),
          child: widget.token.user.email.isEmpty && !_photoChanged
            ? Image(
                image: AssetImage('assets/no-image.png'),
                height: 160,
                width: 160,
                fit: BoxFit.cover,
              ) 
            : ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: _photoChanged 
                ? Image.file(
                    File(_image.path),
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ) 
                : CachedNetworkImage(
                    imageUrl: widget.token.user.imageFullPath,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    height: 160,
                    width: 160,
                    placeholder: (context, url) => Image(
                      image: AssetImage('assets/TronchaToro.png'),
                      fit: BoxFit.cover,
                      height: 160,
                      width: 160,
                    ),
                  ),
              ),        
        ),
        widget.token.user.LoginType == '1' ? Container() : Positioned(
          bottom: 0,
          left: 100,
          child: InkWell(
            onTap: () => _takePicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: Icon(
                  Icons.photo_camera,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ),
        widget.token.user.LoginType == '1' ? Container() : Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () => _selectPicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ),
      ] 
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        controller: _EmailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          errorText: _showEmailError ? _EmailError : null,
          hintText: 'Ingrese su Email...',
          labelText: 'Email',
          //suffixIcon: Icon(Icons.mail),
          prefixIcon: Icon(Icons.mail),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _Email = value;
        },
      ),
    );
  }

  Widget _showName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        controller: _NameController,
        decoration: InputDecoration(
          errorText: _showNameError ? _NameError : null,
          hintText: 'Ingrese sus Nombres...',
          labelText: 'Nombres',
          //suffixIcon: Icon(Icons.mail),
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _Name = value;
        },
      ),
    );
  }

  Widget _showLastName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        controller: _LastNameController,
        decoration: InputDecoration(
          errorText: _showLastNameError ? _LastNameError : null,
          hintText: 'Ingrese sus Apellidos...',
          labelText: 'Apellidos',
          //suffixIcon: Icon(Icons.mail),
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _LastName = value;
        },
      ),
    );
  }

  Widget _showBirtDate() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        readOnly: true,
        controller: _BirtDateController,
        decoration: InputDecoration(
          errorText: _showBirtDateError ? _BirtDateError : null,
          hintText: 'Ingrese su fecha de nacimiento...',
          labelText: 'Fecha de nacimiento',
          //suffixIcon: Icon(Icons.mail),
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _selectedDate = DateFormat("yyyy/MM/dd").parse(value);
        },
        onTap: (){
          _selectDate(context);
        },
      ),
    );
  }

  _selectDate(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2022,12),)
      .then((selectedDate) {
        if(selectedDate!=null){
            _BirtDateController.text = DateFormat("yyyy/MM/dd").format(selectedDate);
        }
    });
  }

  Widget _showAddress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        controller: _AddressController,
        keyboardType: TextInputType.multiline,
        minLines: 2, 
        maxLines: 2,
        decoration: InputDecoration(
          errorText: _showAddressError ? _AddressError : null,
          hintText: 'Ingrese su direcci??n...',
          labelText: 'Direcci??n',
          //suffixIcon: Icon(Icons.mail),
          prefixIcon: Icon(Icons.home),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _Address = value;
        },
      ),
    );
  }

  Widget _showPhoneNumber() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextField(
        enabled: widget.token.user.LoginType != '1',
        keyboardType: TextInputType.number,
        controller: _PhoneNumberController,
        decoration: InputDecoration(
          errorText: _showPhoneNumberError ? _PhoneNumberError : null,
          hintText: 'Ingrese su telefono...',
          labelText: 'Telefono',
          prefixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value){
          _PhoneNumber = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton(
              child: Text('Actualizar usuario'),
              onPressed: () => _RegisterUser(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFF120E43);
                  }
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton(
              child: Text('Cambiar contrase??a'),
              onPressed: () => _ChangrePassword(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return Color(0xFF120E43);
                  }
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _RegisterUser() async {

    if(!await _ValidateFields()){
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

    String base64image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64image = base64Encode(imageBytes);
      _NameImage = _image.name;
    }

    Map<String, dynamic> request = {
      'email': _Email,
      //'Password': _Password,
      'Rol_id' : 1,
      'Name': _Name,
      'LastName': _LastName,
      'BirthDate': DateFormat("yyyy-MM-dd").format(_selectedDate),
      'Address': _Address,
      'PhoneNumber': _PhoneNumber,
      'LoginType': "0",
      'Image': base64image,
      'imageId': _NameImage,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/User/UpdateUser/');
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
        message: response.body,
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    //var body = response.body;

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => HomeScreen(token: widget.token,)
      )
    );
  }

  bool _ValidateFields() {
    bool isValid = true;

    if(_Email.isEmpty){
      _EmailError = 'Por favor digitar un email';
      _showEmailError = true;
      isValid = false;
    }
    else if(!EmailValidator.validate(_Email)){
      isValid = false;
      _showEmailError = true;
      _EmailError = 'Debes ingresar un email valido';
    }
    else{
      _showEmailError = false;
    }

    if(_Name.isEmpty){
      _NameError = 'Por favor digitar su nombre';
      _showNameError = true;
      isValid = false;
    }
    else{
      _showNameError = false;
    }

    if(_LastName.isEmpty){
      _LastNameError = 'Por favor digitar su apellido';
      _showLastNameError = true;
      isValid = false;
    }
    else{
      _showLastNameError = false;
    }

    if(_selectedDate.toString().isEmpty){
      _BirtDateError = 'Por favor digitar su fecha de nacimiento';
      _showBirtDateError = true;
      isValid = false;
    }
    else if(_selectedDate == DateTime.now() || _selectedDate.isAfter(DateTime.now())){
      _BirtDateError = 'Por favor digitar su fecha de nacimiento';
      _showBirtDateError = true;
      isValid = false;
    }
    else{
      _showBirtDateError = false;
    }

    if(_PhoneNumber.isEmpty){
      _PhoneNumberError = 'Por favor digitar su numero de telefono';
      _showPhoneNumberError = true;
      isValid = false;
    }
    else{
      _showPhoneNumberError = false;
    }
    setState(() {});
    return isValid;
  }

  void _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    var camera = cameras.first;
    var responseCamera = await showAlertDialog(
        context: context,
        title: 'Seleccionar c??mara',
        message: '??Qu?? c??mara desea utilizar?',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: 'front', label: 'Delantera'),
          AlertDialogAction(key: 'back', label: 'Trasera'),
          AlertDialogAction(key: 'cancel', label: 'Cancelar'),
        ]
    );
 
    if (responseCamera == 'cancel') {
      return;
    }
 
    if (responseCamera == 'back') {
      camera = cameras.first;
    }
 
    if (responseCamera == 'front') {
      camera = cameras.last;
    }
 
    Response? response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: camera)
      )
    );
    if (response != null) {
      setState(() {
        _photoChanged = true;
        _image = response.result;
      });
    }
  }

  void _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  void _LoadUser() {
    _Email = widget.user.email;
    _EmailController.text = _Email;

    _Name = widget.user.name;
    _NameController.text =  _Name;

    _LastName = widget.user.lastName;
    _LastNameController.text = _LastName;

    _selectedDate = widget.user.birthDate == null ? DateTime(1900) : widget.user.birthDate;
    _BirtDateController.text = DateFormat("yyyy/MM/dd").format(_selectedDate);

    _Address = widget.user.address;
    _AddressController.text = _Address;

    _PhoneNumber = widget.user.phoneNumber;
    _PhoneNumberController.text = _PhoneNumber;
  }

  _ChangrePassword() {}
}