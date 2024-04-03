library figma_to_flutter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//import 'Controller/Controller.dart' as Controller;

class FigmaToFlutter {
  // var apiData;
  // late var node;
  //
  // FigmaToFlutter.getData({required String fileKey,required String id}){
  //   return Controller.getData(fileKey, id);
  //   // node = Controller.getData(fileKey, id);
  //   // print(node is Map);
  //   //
  //   // if(node != null){
  //   //  var view =  Controller.test(node);
  //   // }
  // }

  /// RestApi 요청 후 위젯 반환
  ///
  /// required [fileKey] figma의 파일 키.
  /// required [id]
  /// fileKey와 id는 figma의 url에서 확인 할 수 있음.
  static Future<Widget> getData(
      {required String fileKey, required String id}) async {

    var data = await getDataFromController(fileKey, id);

    return _buildWidgetFromData(data);
  }

  static Future<dynamic> getDataFromController(String fileKey, String id) async {
    var nodesData;
    var document;

    // TODO: 토큰관리

    http.Response response = await http.get(
        Uri.parse('https://api.figma.com/v1/files/$fileKey/nodes?ids=$id'),
        headers: {

        });

    // TODO: 통신 예외처리
    if (response.statusCode == 200) {

      var jsonData = json.decode(response.body);
      var nodesId = id.replaceAll('-', ':');

      nodesData = jsonData['nodes'][nodesId];
      document = nodesData['document'];
      return document;
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Widget _buildWidgetFromData(dynamic node) {
    var document = node;
    Widget? resultWidget;

    // TODO: 예외처리
    if (node['type'] == 'CANVAS') {
      var children = node['children'];
      //test(children['type']);
      return _buildWidgetFromData(children[0]);
    } else if (node['type'] != 'CANVAS') {
      print(node['type']);
      print(node['absoluteBoundingBox']['width']); // width
      print(node['absoluteBoundingBox']['height']); //

      // TODO: 예외처리
      final width = node['absoluteBoundingBox']['width'] ?? 0.0;
      final height = node['absoluteBoundingBox']['height'] ?? 0.0;

      resultWidget = Container(
        width: width,
        height: height,
        color: Colors.blue,
      );

      // TODO: 자식노드가 있을 때 위젯 생성하고 하위 child로 보내야함.
      var children2 = node['children'];
      if(children2.length >= 1){
        print(children2[0]);
      }

      // return resultWidget;
    }

    return resultWidget ?? Container(
      width: 100,
      height: 100,
      color: Colors.red,
      // Use data to build the UI
    );
  }
}