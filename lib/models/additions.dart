class Additions {
  int idAddition = 0;
  String descriptionAddition = '';
  int priceAddition = 0;

  Additions({required this.idAddition, required this.descriptionAddition, required this.priceAddition});

  Additions.fromJson(Map<String, dynamic> json) {
    idAddition = (json['idAddition']);
    descriptionAddition = json['descriptionAddition'];
    priceAddition = json['priceAddition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idAddition'] = this.idAddition;
    data['descriptionAddition'] = this.descriptionAddition;
    data['priceAddition'] = this.priceAddition;
    return data;
  }
}