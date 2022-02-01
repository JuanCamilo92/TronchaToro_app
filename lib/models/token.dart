import 'package:tronchatoro_app/models/user.dart';

class Token {
  String token = '';
  String expiration = '';
  User user = User(
    email: '', 
    rolId: 0, 
    name: '', 
    lastName: '', 
    birthDate: '', 
    address: '', 
    phoneNumber: '', 
    imageId: '', 
    LoginType: '', 
    imageFullPath: '',
    orders: [],
    NOrders: 0);

  Token({required token, required expiration, required user});

  Token.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expiration = json['expiration'];
    user = User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['expiration'] = this.expiration;
    data['user'] = this.user.toJson();
    return data;
  }
}