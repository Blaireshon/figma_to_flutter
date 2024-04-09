library figma_to_flutter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Style.dart';
import 'StyleParser.dart';

//import 'controller/controller.dart' as controller;

class FigmaToFlutter {
  static var checkIsParent = true;

  /// RestApi 요청 후 위젯 반환
  ///
  /// required [fileKey] figma의 파일 키.
  /// required [id]
  /// fileKey와 id는 figma의 url에서 확인 할 수 있음.
  static Future<Widget> getData(
      {required String fileKey, required String id}) async {
    var data = await getDataFromController(fileKey, id);

    return _buildWidgetFromData(data, null);
  }

  static Future<dynamic> getDataFromController(String fileKey,
      String id) async {
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

      return _buildWidgetFromData(node, null);
    } else {
      if (node['type'] == 'TEXT') {
        return _buildTextWidget(node, parentNode);
      }

      else if (node['layoutMode'] != null && node['layoutMode'] == 'HORIZONTAL') {
        print('HORIZONTAL!!!!!');

        return _buildRowWidget(node, parentNode);
      }

    else {
        return _buildFrameWidget(node, parentNode);
      }
      return Container();
    }
  }

  static _buildFrameWidget(dynamic node, dynamic parentNode) {
    /// 자식 노드가 있을 때
    if (node['children'] != null && (node['children'] as List).isNotEmpty) {
      var children = node['children'] as List<dynamic>;
      Style style = styleParser(node, parentNode);

      /// 맨 처음 요소인지 확인하기
      if (checkIsParent) {
        checkIsParent = false;
        return Container(
          //key: GlobalKey(),
          width: style.width,
          height: style.height,
          color: style.color,
          padding: const EdgeInsets.all(0.0),

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
              padding: const EdgeInsets.all(0.0),
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
      Style style = styleParser(node, parentNode);

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


  static _buildRowWidget(dynamic node, dynamic parentNode) {

    /// 자식 노드가 있을 때
    if (node['children'] != null && (node['children'] as List).isNotEmpty) {
      var children = node['children'] as List<dynamic>;
      Style style = styleParser(node, parentNode);
      print('horizontal2222!!!!!');

      return Positioned(
        top: style.positionedY,
        left: style.positionedX,
        child:Expanded( child:Container(
              //key: GlobalKey(),
              width: style.width,
              height: style.height,
          padding: style.padding ?? EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: style.borderRadius,
                border: style.border,
                color: style.color,
              ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // children: children
                  //     .map<Widget>((child) => _buildWidgetFromData(child, node),)
                  //     .toList(),
                  children: List.generate(children.length * 2 - 1, (index) {
                    if (index.isEven) {
                      // 짝수 인덱스일 때는 원래의 자식 위젯을 반환
                      return _buildWidgetFromData(children[index ~/ 2], node);
                    } else {
                      // 홀수 인덱스일 때는 SizedBox를 반환
                      return SizedBox(width: style.itemSpacing);
                    }
                  }),
                ),

            ),
        )
      );

      /// 자식 노드가 없을 때
    } else if (node['children'] == null || (node['children'] as List).isEmpty) {
      Style style = styleParser(node, parentNode);

      return Positioned(
          top: style.positionedY,
          left: style.positionedX,
          child:Container(
            //key: GlobalKey(),
            width: style.width,
            height: style.height,
            decoration: BoxDecoration(
              borderRadius: style.borderRadius,
              border: style.border,
              color: style.color,
            ),
          ))
      ;
    } else {
      return Container();
    }
  }

  //Type : Text
  static _buildTextWidget(dynamic node, dynamic parentNode) {
    Style style = styleParser(node, parentNode);

    var TypeStyle = node['style'];

    /// Text
    var contentText = node['characters'] ?? '';
    return  Container(
          width: style.width,
          height: style.height,

          child: Align(
              alignment: style.alignment ?? Alignment.topLeft,
              child: Text(
                  contentText,
                  overflow: style.textOverFlow,
                  maxLines: style.maxLines,
                textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: style.fontSize ?? 12.0,
                      fontFamily: style.fontFamily ?? 'Roboto',
                      fontWeight: style.fontWeight ?? FontWeight.normal,
                      height: style.lineHeight

                  ))
          )

      );

  }
}
