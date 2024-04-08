import 'dart:ui';

import 'package:flutter/cupertino.dart';

class MappingTypeStyle{
  static FontWeight getFontWeight(dynamic value){
    int fontWeight = int.parse(value.toString());
    switch(fontWeight){
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
    }
    return FontWeight.normal;
  }
  static double getFontSize(dynamic value){
    double? fontSize = double.tryParse(value.toString());
    return fontSize ?? 12.0;
  }
  static String getFontFamily(dynamic value){
    String? fontFamily = value.toString();
    return fontFamily;
  }
  //TODO: textAutoResize이랑 textTruncation 확인 필요
  static TextOverflow? getTextOverFlow(dynamic value){
    String? fontOverFlow = value.toString();
    if(fontOverFlow == 'ENDING'){return TextOverflow.ellipsis; }else{
      return null;
    }

  }
// horizontal : LEFT, RIGHT, CENTER,
  // vertical : TOP, CENTER, BOTTOM
  static Alignment? getAlignment(String horizontal, String vertical){
    final alignmentMap = {
      'LEFT': {
        'TOP': Alignment.topLeft,
        'CENTER': Alignment.centerLeft,
        'BOTTOM': Alignment.bottomLeft,
      },
      'RIGHT': {
        'TOP': Alignment.topRight,
        'CENTER': Alignment.centerRight,
        'BOTTOM': Alignment.bottomRight,
      },
      'CENTER': {
        'TOP': Alignment.topCenter,
        'CENTER': Alignment.center,
        'BOTTOM': Alignment.bottomCenter,
      },
    };
    final horizontalKey = horizontal.toUpperCase();
    final verticalKey = vertical.toUpperCase();

    return alignmentMap[horizontalKey]?[verticalKey] ;

  }
}