library figma_to_flutter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Style.dart';
import 'StyleParser.dart';

//import 'controller/controller.dart' as controller;

class FigmaToFlutter {
  // var apiData;
  // late var node;
  //
  // FigmaToFlutter.getData({required String fileKey,required String id}){
  //   return controller.getData(fileKey, id);
  //   // node = controller.getData(fileKey, id);
  //   // print(node is Map);
  //   //
  //   // if(node != null){
  //   //  var view =  controller.test(node);
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
    print('1');
    var data = await getDataFromController(fileKey, id);
    print('3');
    return _buildWidgetFromData(data, null);
  }

  static Future<dynamic> getDataFromController(String fileKey,
      String id) async {
    var nodesData;
    var document;
print('2');
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
    print('4');
    if (node['type'] == 'CANVAS') {
      // TODO: 캔버스 말고 화면 클릭해야한다고 에러 표시
      print('저기');
      return _buildWidgetFromData(node, null);
    } else {
      if (node['type'] == 'TEXT') {
        print('여기');
        return _buildTextWidget(node, parentNode);
      } else {
        return _buildFrameWidget(node, parentNode);
      }
      return Container();
    }
  }

  static Widget _buildFrameWidget(dynamic node, dynamic parentNode) {
    /// 자식 노드가 있을 때
    if (node['children'] != null && (node['children'] as List).isNotEmpty) {
      var children = node['children'] as List<dynamic>;
      Style style = styleParser(node,parentNode);

      // /// size
      // Map<String, double> size = getSize(node);
      //
      // /// position
      // Map<String, double> xy = getPosition(node, parentNode);

      // /// borderRadius
      // BorderRadius borderRadius = getBorderRadius(node);

      /// 맨 처음 요소인지 확인하기
      if (checkIsParent) {
        checkIsParent = false;
        return Container(
          //key: GlobalKey(),
          width: style.width,
          height: style.height,
          color: style.color,

          child: Stack(
            children: children
                .map<Widget>((child) => _buildWidgetFromData(child, node))
                .toList(),
          ),
        );
      } else {
        return Positioned(
            top: style.positionedY,
            left: style.positionedX,
            child: Container(
              //key: GlobalKey(),
              width: style.width,
              height: style.height,
              decoration: BoxDecoration(
                  borderRadius: style.borderRadius,
                border: style.border,
                color: style.color,
              ),
              child: Stack(
                children: children
                    .map<Widget>((child) => _buildWidgetFromData(child, node))
                    .toList(),
              ),
            ));
      }

      /// 자식 노드가 없을 때
    } else if (node['children'] == null || (node['children'] as List).isEmpty) {
      Style style = styleParser(node,parentNode);

      // /// size
      // Map<String, double> size = getSize(node);
      //
      // /// position
      // Map<String, double> xy = getPosition(node, parentNode);


      // /// borderRadius
      // BorderRadius borderRadius = getBorderRadius(node);

      return Positioned(
          top: style.positionedY,
          left: style.positionedX,
          child: Container(
            //key: GlobalKey(),
            width: style.width,
            height: style.height,
            decoration: BoxDecoration(
               borderRadius: style.borderRadius,
                border: style.border,
                color: style.color,
            ),
          )
      );
    } else {
      return Container();
    }
  }

  //Type : Text
  static _buildTextWidget(dynamic node, dynamic parentNode) {
    Style style = styleParser(node,parentNode);

    // /// position
    // Map<String, double> xy = getPosition(node, parentNode);
    var TypeStyle = node['style'];

    /// Text
    var contentText = node['characters'] ?? '';
    return Positioned(
      top: style.positionedY,
      left: style.positionedX,
      child: Text(
          contentText,
          style: TextStyle(
            fontSize: TypeStyle['fontSize'] ?? 12.0,
            fontFamily: TypeStyle['fontFamily'] ?? 'Monospace',
            //fontWeight: TypeStyle['fontWeight'] ?? FontWeight.normal,

          )),
    );
  }
}
