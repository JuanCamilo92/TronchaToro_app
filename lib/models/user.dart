import 'package:tronchatoro_app/models/order.dart';

class User {
  String email = '';
  int rolId = 0;
  String name = '';
  String lastName = '';
  DateTime birthDate = DateTime(2000);
  String address = '';
  String phoneNumber = '';
  String imageId = '';
  String LoginType = '';
  String imageFullPath = '';
  List<Order> orders = [];
  int NOrders = 0;

  User(
      {required email,
      required rolId,
      required name,
      required lastName,
      required birthDate,
      required address,
      required phoneNumber,
      required imageId,
      required LoginType,
      required imageFullPath,
      required orders,
      required NOrders});

  User.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    rolId = json['rol_id'];
    name = json['name'];
    lastName = json['lastName'];
    birthDate = json['birthDate'] != null ? DateTime.parse(json['birthDate']): DateTime(1900);
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    imageId = json['imageId'] == null ? '' : json['imageId'];
    LoginType = json['loginType'] == null ? '' : json['loginType'];
    imageFullPath = json['imageFullPath'];
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders.add(new Order.fromJson(v));
      });
    }
    NOrders = json['nOrders'] == null ? 0 : json['nOrders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['rol_id'] = this.rolId;
    data['name'] = this.name;
    data['lastName'] = this.lastName;
    data['birthDate'] = this.birthDate;
    data['address'] = this.address;
    data['phoneNumber'] = this.phoneNumber;
    data['imageId'] = this.imageId;
    data['loginType'] = this.LoginType;
    data['imageFullPath'] = this.imageFullPath;
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    data['nOrders'] = this.NOrders;
    return data;
  }
}