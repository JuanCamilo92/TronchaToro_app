import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tronchatoro_app/helpers/constans.dart';
import 'package:tronchatoro_app/models/Foods.dart';
import 'package:tronchatoro_app/models/additions.dart';
import 'package:tronchatoro_app/models/response.dart';
import 'package:tronchatoro_app/models/token.dart';
import 'package:tronchatoro_app/models/user.dart';

class ApiHelper{

  static Future<Response> put(String controller, Map<String, dynamic> request, Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
     var url = Uri.parse('${Constans.apiUrl}${controller}');

    var json = jsonEncode(request);

    var response = await http.put(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
      body: json,
    );
    
    if(response.statusCode >= 400)
    {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> post(String controller, Map<String, dynamic> request, Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
     var url = Uri.parse('${Constans.apiUrl}$controller');

    var json = jsonEncode(request);

    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
      body: json,
    );
    
    if(response.statusCode >= 400)
    {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> delete(String controller, String id, Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
     var url = Uri.parse('${Constans.apiUrl}$controller$id');

    var response = await http.delete(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );
    
    if(response.statusCode >= 400)
    {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

static Future<Response> deletePut(String controller, String id, Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
     var url = Uri.parse('${Constans.apiUrl}$controller$id');

    var response = await http.put(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );
    
    if(response.statusCode >= 400)
    {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static bool _validToken(Token token) {
    if(DateTime.parse(token.expiration).isAfter(DateTime.now())){
          return true;
    }
    else{
      return false;
    }
  }

  static Future<Response> postNoToken(String controller, Map<String, dynamic> request) async {

    
    var url = Uri.parse('${Constans.apiUrl}$controller');
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }

  static Future<Response> getFoods(Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
      var url = Uri.parse('${Constans.apiUrl}/api/Food/GetFoods');

      var response = await http.get(
        url,
        headers: {
          'content-type' : 'application/json',
          'accept' : 'application/json',
          'authorization': 'bearer ${token.token}',
        },
      );

      var body = response.body;
      if(response.statusCode >= 400)
      {
        return Response(isSuccess: false, message: body);
      }

      List<Foods> list = [];
      var decodedJson = jsonDecode(body);
      if(decodedJson != null)
      {
        for (var item in decodedJson) {
          list.add(Foods.fromJson(item));
        }
      }

      return Response(isSuccess: true, result: list);
    }

  static Future<Response> getUser(Token token) async {
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
      var url = Uri.parse('${Constans.apiUrl}/api/User/GetUserInfo/${token.user.email}');

      var response = await http.get(
        url,
        headers: {
          'content-type' : 'application/json',
          'accept' : 'application/json',
          'authorization': 'bearer ${token.token}',
        },
      );

      var body = response.body;
      if(response.statusCode >= 400)
      {
        return Response(isSuccess: false, message: body);
      }

      var decodedJson = jsonDecode(body);
      return Response(isSuccess: true, result: User.fromJson(decodedJson));
  }

  static Future<Response> getUsers(Token token) async {
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
      var url = Uri.parse('${Constans.apiUrl}/api/User/GetUsers');

      var response = await http.get(
        url,
        headers: {
          'content-type' : 'application/json',
          'accept' : 'application/json',
          'authorization': 'bearer ${token.token}',
        },
      );

      var body = response.body;
      if(response.statusCode >= 400)
      {
        return Response(isSuccess: false, message: body);
      }

      List<User> list = [];
      var decodedJson = jsonDecode(body);
      if(decodedJson != null)
      {
        for (var item in decodedJson) {
          list.add(User.fromJson(item));
        }
      }

      return Response(isSuccess: true, result: list);
  }

  static Future<Response> GetOrdersInfo(Token token, User user, int State) async {
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
      var url = Uri.parse('${Constans.apiUrl}/api/User/GetOrdersInfo/${user.email}/${State}');

      var response = await http.get(
        url,
        headers: {
          'content-type' : 'application/json',
          'accept' : 'application/json',
          'authorization': 'bearer ${token.token}',
        },
      );

      var body = response.body;
      if(response.statusCode >= 400)
      {
        return Response(isSuccess: false, message: body);
      }

      var decodedJson = jsonDecode(body);
      return Response(isSuccess: true, result: User.fromJson(decodedJson));
  }

static Future<Response> getAdditions(Token token) async{
    if(!_validToken(token)){
      return Response(isSuccess: false, message: 'Su credenciales se han vencido, por favor cierre sesion y vuelva a ingresar al sistema.');
    }
      var url = Uri.parse('${Constans.apiUrl}/api/Addition/GetAdditions');

      var response = await http.get(
        url,
        headers: {
          'content-type' : 'application/json',
          'accept' : 'application/json',
          'authorization': 'bearer ${token.token}',
        },
      );

      var body = response.body;
      if(response.statusCode >= 400)
      {
        return Response(isSuccess: false, message: body);
      }

      List<Additions> list = [];
      var decodedJson = jsonDecode(body);
      if(decodedJson != null)
      {
        for (var item in decodedJson) {
          list.add(Additions.fromJson(item));
        }
      }

      return Response(isSuccess: true, result: list);
    }
}