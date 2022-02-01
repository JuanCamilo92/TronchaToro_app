import 'package:tronchatoro_app/models/orderDetail.dart';

class Order {
  int idOrder = 0;
  String nOrder = '';
  List<OrderDetails> orderDetails = [];
  int Total = 0;
  int IdStatePay = 0;
  int IdStateTran = 0;
  String StatePay = '';
  String StateTran = '';

  Order({required this.idOrder, required this.nOrder, required this.orderDetails, required this.Total,
        required this.IdStatePay, required this.IdStateTran, required this.StatePay, required this.StateTran});

  Order.fromJson(Map<String, dynamic> json) {
    idOrder = json['idOrder'];
    nOrder = json['nOrder'];
    if (json['orderDetails'] != null) {
      orderDetails = [];
      json['orderDetails'].forEach((v) {
        orderDetails.add(new OrderDetails.fromJson(v));
      });
    }
    Total = json['total'];
    IdStatePay = json['idStatePay'];
    IdStateTran = json['idStateTran'];
    StatePay = json['statePay'];
    StateTran = json['stateTran'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idOrder'] = this.idOrder;
    data['nOrder'] = this.nOrder;
    if (this.orderDetails != null) {
      data['orderDetails'] = this.orderDetails.map((v) => v.toJson()).toList();
    }
    data['total'] = this.Total;
    data['idStatePay'] = this.IdStatePay;
    data['idStateTran'] = this.IdStateTran;
    data['statePay'] = this.StatePay;
    data['stateTran'] = this.StateTran;
    return data;
  }
}