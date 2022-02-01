import 'package:tronchatoro_app/models/Foods.dart';
import 'package:tronchatoro_app/models/ordersDetailAddition.dart';

class OrderDetails {
  int idDetail = 0;
  int idOrder = 0;
  int idFood = 0;
  List<Foods> foods = [];
  List<OrdersDetailAdditions> ordersDetailAdditions = [];
  int Quantity = 0;

  OrderDetails(
      {required this.idDetail,
      required this.idOrder,
      required this.idFood,
      required this.foods,
      required this.ordersDetailAdditions,
      required this.Quantity});

  OrderDetails.fromJson(Map<String, dynamic> json) {
    idDetail = json['idDetail'];
    idOrder = json['idOrder'];
    idFood = json['idFood'];
    if (json['foods'] != null) {
      foods = [];
      json['foods'].forEach((v) {
        foods.add(new Foods.fromJson(v));
      });
      Quantity = json['quantity'];
    }
    if (json['ordersDetailAdditions'] != null) {
      ordersDetailAdditions = [];
      json['ordersDetailAdditions'].forEach((v) {
        ordersDetailAdditions.add(new OrdersDetailAdditions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idDetail'] = this.idDetail;
    data['idOrder'] = this.idOrder;
    data['idFood'] = this.idFood;
    if (this.foods != null) {
      data['foods'] = this.foods.map((v) => v.toJson()).toList();
    }
    if (this.ordersDetailAdditions != null) {
      data['ordersDetailAdditions'] =
          this.ordersDetailAdditions.map((v) => v.toJson()).toList();
    }
    data['quantity'] = this.Quantity;
    return data;
  }
}