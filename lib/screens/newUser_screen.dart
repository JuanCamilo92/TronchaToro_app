import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tronchatoro_app/components/loader_component.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({ Key? key }) : super(key: key);

  @override
  _NewUserScreenState createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  bool _showLoader = false;

  String _Email = '';
  String _EmailError = '';
  bool _showEmailError = false;
  TextEditingController _EmailController = TextEditingController();

  bool _obscurePassword = false;
  String _Password = '';
  String _PasswordError = '';
  bool _showPasswordError = false;
  TextEditingController _PasswordController = TextEditingController();

  String _PasswordConfirm = '';
  String _PasswordConfirmError = '';
  bool _showPasswordConfirmError = false;
  TextEditingController _PasswordConfirmController = TextEditingController();

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
  /*void initState() {

    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo usuario') ,
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
            _showButtons(),
            _showPasswords(),
            _showPasswordConfirm(),
          ],
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      child: Expanded(
        child: TextField(
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
      ),
    );
  }

  Widget _showName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Expanded(
        child: TextField(
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
      ),
    );
  }

  Widget _showLastName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Expanded(
        child: TextField(
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
      ),
    );
  }

  Widget _showBirtDate() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Expanded(
        child: TextField(
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
      child: Expanded(
        child: TextField(
          controller: _AddressController,
          keyboardType: TextInputType.multiline,
          minLines: 2, 
          maxLines: 2,
          decoration: InputDecoration(
            errorText: _showAddressError ? _AddressError : null,
            hintText: 'Ingrese su dirección...',
            labelText: 'Dirección',
            //suffixIcon: Icon(Icons.mail),
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value){
            _Address = value;
          },
        ),
      ),
    );
  }

  Widget _showPhoneNumber() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Expanded(
        child: TextField(
          keyboardType: TextInputType.number,
          controller: _PhoneNumberController,
          decoration: InputDecoration(
            errorText: _showPhoneNumberError ? _PhoneNumberError : null,
            hintText: 'Ingrese su telefono...',
            labelText: 'Telefono',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value){
            _PhoneNumber = value;
          },
        ),
      ),
    );
  }

  Widget _showPasswordConfirm() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Expanded(
        child: TextField(
          controller: _PasswordController,
          obscureText: !_obscurePassword,
          decoration: InputDecoration(
            errorText: _showPasswordError ? _PasswordError : null,
            hintText: 'Ingrese una contraseña...',
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.person),
            suffixIcon: IconButton(
              icon: _obscurePassword ?  Icon(Icons.visibility_off) : Icon(Icons.lock),
              onPressed: (){
                  setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value){
            _Password = value;
          },
        ),
      ),
    );
  }

  Widget _showPasswords() {
    return Container(

    );
  }
}