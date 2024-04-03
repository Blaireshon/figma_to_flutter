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
  static var baseWidth;
  static var baseHeight;
  static var checkIsParent = true;

  /// RestApi 요청 후 위젯 반환
  ///
  /// required [fileKey] figma의 파일 키.
  /// required [id]
  /// fileKey와 id는 figma의 url에서 확인 할 수 있음.
  static Future<Widget> getData(
      {required String fileKey, required String id}) async {

    var data = await getDataFromController(fileKey, id);

    return _buildWidgetFromData(data,null);
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




  // static Widget _buildWidgetFromData(dynamic node) {
  //   var document = node;
  //   Widget? resultWidget;
  //
  //   // TODO: 예외처리
  //   /// CANVAS figma 화면
  //   if (node['type'] == 'CANVAS') {
  //     var children = node['children'];
  //     //test(children['type']);
  //     return _buildWidgetFromData(children[0]);
  //   } else if (node['type'] != 'CANVAS') {
  //     print(node['type']);
  //     print(node['absoluteBoundingBox']['width']); // width
  //     print(node['absoluteBoundingBox']['height']); //
  //
  //     // TODO: 예외처리
  //     final width = node['absoluteBoundingBox']['width'] ?? 0.0;
  //     final height = node['absoluteBoundingBox']['height'] ?? 0.0;
  //
  //     resultWidget = Container(
  //       width: width,
  //       height: height,
  //       color: Colors.blue,
  //     );
  //
  //     // TODO: 자식노드가 있을 때 위젯 생성하고 하위 child로 보내야함.
  //     var children2 = node['children'];
  //     if(children2.length >= 1){
  //       print(children2[0]);
  //     }
  //
  //     // return resultWidget;
  //   }
  //
  //   return resultWidget ?? Container(
  //     width: 100,
  //     height: 100,
  //     color: Colors.red,
  //     // Use data to build the UI
  //   );
  // }

  static Widget _buildWidgetFromData(dynamic node, dynamic parentNode) {
    if (node['type'] == 'CANVAS') {

      // TODO: 캔버스 말고 화면 클릭해야한다고 에러 표시
      return _buildWidgetFromData(node,null);
    } else if(node['type'] != 'CANVAS') {
      return _buildFrameWidget(node, parentNode);
    } else {
      return Container();
    }
  }

  static Widget _buildFrameWidget(dynamic node, dynamic parentNode) {

    if (node['children'] != null && (node['children'] as List).isNotEmpty) {
      var children = node['children'] as List<dynamic>;
      var width =  node['absoluteBoundingBox']['width'] ?? 0.0;
      var height =  node['absoluteBoundingBox']['height'] ?? 0.0;
      var x;
      var y;
      print('baseWidth $baseWidth');

      // 밑바탕되는 요소의 넓이와 높이
      // baseWidth = (baseWidth ?? node['absoluteBoundingBox']['width']/2).toDouble();
      // baseHeight = (baseHeight ?? node['absoluteBoundingBox']['height']/2).toDouble();
      baseWidth = (baseWidth ?? 0.0 - node['absoluteBoundingBox']['x']).toDouble();
      baseHeight = (baseHeight ?? 0.0 - node['absoluteBoundingBox']['y']).toDouble();

      print('baseWidth $baseWidth');
      // var x = (baseWidth + node['absoluteBoundingBox']['x']).round().toDouble().clamp(0.0, baseWidth*2);
      // var y = (baseHeight + node['absoluteBoundingBox']['y']).round().toDouble().clamp(0.0, baseHeight*2);


        x = (node['absoluteBoundingBox']['x'] + baseWidth).toDouble();
        y = (node['absoluteBoundingBox']['y'] + baseHeight).toDouble();



      print(x is double);
      print(y is double);

      print('x $x');
      print('y $y');
      print(node['absoluteBoundingBox']['y'] is double);

      if(checkIsParent){

        checkIsParent = false;
        return Container(
          //key: GlobalKey(),
          width: node['absoluteBoundingBox']['width'],
          height: node['absoluteBoundingBox']['height'],
          //color: _getColor(node['background']),
          color: node['type'] == 'FRAME' ? Colors.blue : Colors.red,
          child: Stack(
            children: children.map<Widget>((child) => _buildWidgetFromData(child,node))
                .toList(),
          ),
        );
      }else{

        return Positioned(
            top:y,
            left:x,
            child:Container(
              //key: GlobalKey(),
              width: node['absoluteBoundingBox']['width'],
              height: node['absoluteBoundingBox']['height'],
              //color: _getColor(node['background']),
              color: node['type'] == 'FRAME' ? Colors.blue : Colors.red,
              child: Stack(
                children: children.map<Widget>((child) => _buildWidgetFromData(child,node))
                    .toList(),
              ),
            ));
      }


    } else if (node['children'] == null || (node['children'] as List).isEmpty) {
      // baseWidth ??= node['absoluteBoundingBox']['width']/2;
      // baseHeight ??= node['absoluteBoundingBox']['height']/2;
      //
      // var x = baseWidth + node['absoluteBoundingBox']['x'];
      // var y = baseHeight + node['absoluteBoundingBox']['y'];
      //
      // print('x $x');
      // print('y $y');

      baseWidth = (baseWidth ?? 0.0 - node['absoluteBoundingBox']['x']).toDouble();
      baseHeight = (baseHeight ?? 0.0 - node['absoluteBoundingBox']['y']).toDouble();

      var parentX;
      var parentY;
      var x = (node['absoluteBoundingBox']['x'] + baseWidth).toDouble();
      var y = (node['absoluteBoundingBox']['y'] + baseHeight).toDouble();
      print('x $x');
      print('y $y');


      if(parentNode != null){
        parentX =  (parentNode['absoluteBoundingBox']['x'] + baseWidth).toDouble();
        parentY = (parentNode['absoluteBoundingBox']['y'] + baseHeight).toDouble();
        x = parentX - x;
        y = parentY - y;
      }

      return Positioned(
        top:y,
        left:x,
        child: Container(
          //key: GlobalKey(),
        width: node['absoluteBoundingBox']['width'],
        height: node['absoluteBoundingBox']['height'],
        color:node['type'] == 'RECTANGLE' ? Colors.blue : Colors.red
      ),
      );
    } else {
      return Container();
    }
  }

  static Color _getColor(dynamic background) {
    if (background == null) return Colors.transparent;
    var color = background[0]['color'];
    return Color.fromRGBO(
      (color['r'] * 255).toInt(),
      (color['g'] * 255).toInt(),
      (color['b'] * 255).toInt(),
      1.0,
    );
  }
}