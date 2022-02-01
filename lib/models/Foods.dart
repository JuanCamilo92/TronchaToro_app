class Foods {
  int idFood = 0;
  String descriptionFood = '';
  int priceFood = 0;
  String imageId = '';
  String observations = '';
  String imageFullPath = '';

  Foods(
      {required this.idFood,
      required this.descriptionFood,
      required this.priceFood,
      required this.imageId,
      required this.observations,
      required this.imageFullPath});

  Foods.fromJson(Map<String, dynamic> json) {
    idFood = json['idFood'];
    descriptionFood = json['descriptionFood'];
    priceFood = json['priceFood'];
    imageId = json['imageId'];
    observations = json['observations'];
    imageFullPath = json['imageFullPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idFood'] = this.idFood;
    data['descriptionFood'] = this.descriptionFood;
    data['priceFood'] = this.priceFood;
    data['imageId'] = this.imageId;
    data['observations'] = this.observations;
    data['imageFullPath'] = this.imageFullPath;
    return data;
  }
}