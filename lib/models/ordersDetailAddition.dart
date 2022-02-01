import 'package:tronchatoro_app/models/additions.dart';

class OrdersDetailAdditions {
  int idOrderDetailAddition = 0;
  int idorderDetail = 0;
  int idAddition = 0;
  List<Additions> additions = [];
  int Quantity = 0;

  OrdersDetailAdditions(
      {required this.idOrderDetailAddition,
      required this.idorderDetail,
      required this.idAddition,
      required this.additions,
      required this.Quantity});

  OrdersDetailAdditions.fromJson(Map<String, dynamic> json) {
    idOrderDetailAddition = json['idOrderDetailAddition'];
    idorderDetail = json['idorderDetail'];
    idAddition = json['idAddition'];
    if (json['additions'] != null) {
      additions = [];
      json['additions'].forEach((v) {
        additions.add(new Additions.fromJson(v));
      });
    }
    Quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idOrderDetailAddition'] = this.idOrderDetailAddition;
    data['idorderDetail'] = this.idorderDetail;
    data['idAddition'] = this.idAddition;
    if (this.additions != null) {
      data['additions'] = this.additions.map((v) => v.toJson()).toList();
    }
    data['quantity'] = this.Quantity;
    return data;
  }
}