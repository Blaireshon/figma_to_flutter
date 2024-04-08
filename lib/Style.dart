import 'dart:ui';
import 'package:flutter/cupertino.dart';

class Style{
  Color? color;
  String? fontFamily;
  //FontStyle? fontStyle;
  FontWeight? fontWeight;
  double? fontSize;
  TextOverflow? textOverFlow;
  int? maxLines;
  double? lineHeight;
  Alignment? alignment;
  double? width;
  double? height;
 // TextAlign? textAlign;
  double? positionedX;
  double? positionedY;
  BorderRadius? borderRadius;
  Border? border;

  Style({
    this.color,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.textOverFlow,
    this.maxLines,
    this.lineHeight,
    this.alignment,
    this.width,
    this.height,
    this.positionedX,
    this.positionedY,
    this.borderRadius,
    this.border,
});

}