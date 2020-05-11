import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_obp_flutter/model/model.dart';
import 'package:http/http.dart';
import 'constant.dart';
import 'package:http/http.dart' as http;

class HttpRequest {
  HttpRequest._privateConstructor();

  static final HttpRequest instance = HttpRequest._privateConstructor();

  String _buildUrl(String url, Map<String, dynamic> headers) {
    if(headers == null || headers.isEmpty) {
      return url;
    } else if(url.contains(RegExp(r'\?.+?=.+'))) {
      String queryPart = headers.keys.map((key) => '$key=${headers[key]}').join('&');
      return url + '&' + queryPart;
    } else {
      String queryPart = headers.keys.map((key) => '$key=${headers[key]}').join('&');
      if(url.contains(RegExp(r'\?.+?=.+'))) {
        return url + '&' + queryPart;
      } else {
        return url + '?' + queryPart;
      }
    }
  }

  ObpResponse _extractResponse(Response response) {
    if(response.statusCode.toString().startsWith('20')) {
      var body = jsonDecode(response.body);
      return ObpResponse(code: response.statusCode, data: body);
    } else {
      try {
        var body = jsonDecode(response.body);
        ErrorMessage errorMessage = ErrorMessage.fromJson(body);
        return ObpResponse(code: errorMessage.code, message: errorMessage.message);
      } catch (e) {
        return ObpResponse(code: response.statusCode, message: 'Unknown Server Error.');
      }
    }
  }

  Future<ObpResponse> get(String url,
          {Map<String, String> headers, Map<String, dynamic> params}) async {
    Response response = await http.get(_buildUrl(url, params), headers: headers);
    return _extractResponse(response);
  }

  Future<ObpResponse>  delete(String url,
          {Map<String, String> headers, Map<String, dynamic> params}) async {
    Response response = await http.delete(_buildUrl(url, params), headers: headers);
    return _extractResponse(response);
  }

  Future<ObpResponse>  post(String url,
          {Map<String, String> headers,
          dynamic data,
          Map<String, dynamic> params}) async {
    Response response;
    try {
      response = await http.post(_buildUrl(url, params), headers: headers, body: data);
    } catch (e) {
      print(e);
    }
    return _extractResponse(response);
  }

  Future<ObpResponse>  put(String url,
          {Map<String, String> headers,
          dynamic data,
          Map<String, dynamic> params}) async {
    Response response = await http.put(_buildUrl(url, params), headers: headers, body: data);
    return _extractResponse(response);
  }
}

HttpRequest httpRequest = HttpRequest.instance;