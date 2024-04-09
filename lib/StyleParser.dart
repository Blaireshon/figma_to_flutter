import 'dart:ui';

import 'package:flutter/material.dart';

import 'Style.dart';
import 'TypeStyleParser.dart';

Style styleParser(dynamic node, dynamic parentNode) {
  Style style = Style();
  dynamic styleMap = node;

  styleMap.forEach((key, value) {
    if (value != null) {
      switch (key) {
        /// TODO: value가 List. 여러개일때 어떻게 적용되는지 확인 필요
        case 'fills':
          //color
          if (value.length == 0) {
            style.color = Colors.transparent;
          } else {
            var fillsColor = value[0]['color'];
            style.color = MappingStyle.getColor(fillsColor);
          }

          break;

        //fontFamily
        case 'style':
          //print('style');
          MappingStyle.getTypeStyle(value, style);

          break;

        // width, height, x, y
        case 'absoluteBoundingBox':
          var parentAbsoluteBoundingBox = parentNode?['absoluteBoundingBox'];

          Map<String, double> absoluteBoundingBox =
              MappingStyle.getPosition(value, parentAbsoluteBoundingBox);

          style.positionedX = absoluteBoundingBox['x'];
          style.positionedY = absoluteBoundingBox['y'];
          style.width = absoluteBoundingBox['width'];
          style.height = absoluteBoundingBox['height'];

          break;

        //모든 모서리에 대해 단일 반경이 설정된 경우 직사각형의 각 모서리 반경
        case 'cornerRadius':
          style.borderRadius = MappingStyle.getBorderRadiusAll(value);
          break;

        //직사각형의 각 모서리 반경의 길이가 4인 배열(왼쪽 상단에서 시작하여 시계 방향)
        case 'rectangleCornerRadii':
          style.borderRadius = MappingStyle.getBorderRadiusOnly(value);
          break;

        //border 두께
        case 'strokeWeight' || 'individualStrokeWeights' || 'strokes':
          if (style.border != null) {
            break;
          } else {
            var strokes =
                node['strokes'].length == 0 ? null : node['strokes'][0];
            var strokeWeight = node['strokeWeight'];
            var individualStrokeWeights = node['individualStrokeWeights'];

            style.border = MappingStyle.getStrokeStyle(
                strokes, strokeWeight, individualStrokeWeights);
          }

          break;
        case 'paddingLeft'||'paddingRight'||'paddingTop'||'paddingBottom':
          double left = MappingStyle.getDouble(node['paddingLeft']) ?? 0.0;
          double right = MappingStyle.getDouble(node['paddingRight']) ?? 0.0;
          double top = MappingStyle.getDouble(node['paddingTop']) ?? 0.0;
          double bottom = MappingStyle.getDouble(node['paddingBottom']) ?? 0.0;

          style.padding = MappingStyle.getPadding(left, right, top, bottom);

          break;

        case 'layoutMode':
          // HORIZONTAL : row
        // VERTICAL : column
          break;
        case'itemSpacing':
          double itemSpacing = MappingStyle.getDouble(node['itemSpacing']) ?? 0.0;
          style.itemSpacing = itemSpacing;
          // sizedbox(width:20)
          break;
      }
    }
  });
  return style;
}

class MappingStyle {
  static int? getInt(dynamic value){
    int? intValue = int.parse(value.toString());
    return intValue;
  }

  static double? getDouble(dynamic value){
    double? doubleValue = double.parse(value.toString());
    return doubleValue;
  }

  static Color getColor(dynamic fillsColor) {
    var color = fillsColor;

    return Color.fromRGBO(
      (color['r'] * 255).toInt(),
      (color['g'] * 255).toInt(),
      (color['b'] * 255).toInt(),
      1.0,
    );
  }

  // 위치 x, y 구하기
  static Map<String, double> getPosition(dynamic child, dynamic parent) {
    double x, y, width, height;

    double childX = child['x'] ?? 0.0;
    double childY = child['y'] ?? 0.0;
    double childWidth = child['width'] ?? 0.0;
    double childHeight = child['height'] ?? 0.0;

    if (parent != null) {
      double parentX = parent['x'] ?? 0.0;
      double parentY = parent['y'] ?? 0.0;

      x = (childX - parentX).abs();
      y = (childY - parentY).abs();
    } else {
      x = (0.0 - childX).abs();
      y = (0.0 - childY).abs();
    }

    width = childWidth;
    height = childHeight;

    return {'x': x, 'y': y, 'width': width, 'height': height};
  }

  // borderRadiusAll
  static BorderRadius getBorderRadiusAll(dynamic cornerRadiusAll) {
    var borderRadius = cornerRadiusAll ?? 0.0;

    BorderRadius borderRadiusValue = BorderRadius.circular(borderRadius);

    return borderRadiusValue;
  }

  static BorderRadius? getBorderRadiusOnly(dynamic cornerRadiusOnly) {
    List<double> borderRadius = [0.0, 0.0, 0.0, 0.0];

    if (cornerRadiusOnly == null) {
      // return BorderRadius.circular(0.0);
      return null;
    } else {
      if (cornerRadiusOnly is List && cornerRadiusOnly.length == 4) {
        for (int i = 0; i < cornerRadiusOnly.length; i++) {
          borderRadius[i] =
              double.tryParse(cornerRadiusOnly[i].toString()) ?? 0.0;
        }
      } else {
        // return BorderRadius.circular(0.0);
        return null;
      }

      return BorderRadius.only(
        topLeft: Radius.circular(borderRadius[0]),
        topRight: Radius.circular(borderRadius[1]),
        bottomRight: Radius.circular(borderRadius[2]),
        bottomLeft: Radius.circular(borderRadius[3]),
      );
    }
  }

  // border
  static Border getStrokeStyle(
      dynamic strokes, dynamic strokeWeight, dynamic individualStrokeWeights) {
    double width = double.tryParse(strokeWeight.toString()) ?? 0.0;
    Color color;
    if (strokes != null) {
      color = getColor(strokes['color']);
    } else {
      color = Colors.transparent;
    }
    if (individualStrokeWeights == null) {
      return Border.all(width: width, color: color);
    } else {
      var top = double.tryParse(individualStrokeWeights['top'].toString());
      var right = double.tryParse(individualStrokeWeights['right'].toString());
      var bottom =
          double.tryParse(individualStrokeWeights['bottom'].toString());
      var left = double.tryParse(individualStrokeWeights['left'].toString());

      return Border(
        top: top != 0.0
            ? BorderSide(
                width: top ?? 0.0,
              )
            : BorderSide.none,
        right: right != 0.0 ? BorderSide(width: right ?? 0.0) : BorderSide.none,
        bottom:
            bottom != 0.0 ? BorderSide(width: bottom ?? 0.0) : BorderSide.none,
        left: left != 0.0 ? BorderSide(width: left ?? 0.0) : BorderSide.none,
      );
    }

    return Border.all(width: width, color: color);
  }

  static EdgeInsets getPadding(double paddingLeft, double paddingRight, double paddingTop, double paddingBottom){
    double left = paddingLeft;
    double right = paddingRight;
    double top = paddingTop;
    double bottom = paddingBottom;

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  static void getTypeStyle(dynamic typeStyle, Style style) {
    dynamic typeStyleMap = typeStyle;

    typeStyleMap.forEach((key, value) {
      if (value != null) {
        switch (key) {
          case 'fontFamily':
            style.fontFamily = MappingTypeStyle.getFontFamily(value);
            break;
          case 'fontPostScriptName':
            break;
          case 'fontWeight':
            style.fontWeight = MappingTypeStyle.getFontWeight(value);
            break;
          case 'textTruncation':
            style.textOverFlow = MappingTypeStyle.getTextOverFlow(value);
            break;
          case 'maxLines':
            style.maxLines = MappingStyle.getInt(value);
            break;
          case 'fontSize':
            style.fontSize = MappingTypeStyle.getFontSize(value);
            break;
          case 'textAlignHorizontal' || 'textAlignVertical':
            if (style.alignment != null) {
              break;
            } else {
              String horizontal = typeStyle['textAlignHorizontal'].toString();
              String vertical = typeStyle['textAlignVertical'].toString();

              style.alignment = MappingTypeStyle.getAlignment(horizontal,vertical) ?? Alignment.topLeft;
            }
            break;
          case'letterSpacing':
            break;
          case 'lineHeightPx':
            break;
          case 'lineHeightPercent':
            break;
          case 'lineHeightUnit':
            break;
          case 'lineHeightPercentFontSize':
            double lineHeight = double.tryParse(value.toString())!/100;
            style.lineHeight = lineHeight;
            break;
        }
      }
    });
  }
}
