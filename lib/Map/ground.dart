import 'dart:math';
import 'dart:ui';
import 'package:BWO/Effects/FoamWaterEffect.dart';
import 'package:BWO/Effects/WaterStarsEffect.dart';
import 'package:BWO/Map/Tile.dart';
import 'package:BWO/game_controller.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Ground extends Tile {
  WaterStarsEffect waterStarsEffect;
  FoamWaterEffect foamWaterEffect = new FoamWaterEffect();
  Sprite grass;

  static const WATER = 95;
  static const LOW_WATER = 110;
  static const LOW_SAND = 112;
  static const SAND = 118;
  static const LOW_GRASS = 140;

  Ground(int posX, int posY, int height, int size, Color color)
      : super(posX, posY, height, size, color) {
    var tileColor = getTileDetailsBasedOnHight(this.height);
    boxPaint.color = color != null ? color : tileColor;

    waterStarsEffect = WaterStarsEffect(boxRect);

    
  }

  void draw(Canvas c) {
    if (height >= 108 && height <= 110) {
      boxPaint.color = foamWaterEffect.getFoamColor(height, posX, posY);//Colors.blue[200];
    }
    c.drawRect(boxRect, boxPaint);

    if(grass != null){
      grass.renderScaled(c, Position(boxRect.left, boxRect.top), scale: 1);
    }

    if (height < 107) {
      waterStarsEffect.blinkWaterEffect(c);
    }
  }

  Color getTileDetailsBasedOnHight(int heightLvl) {
    this.height = heightLvl;    
    var green = 255 - heightLvl;

    if(heightLvl > 142 && heightLvl < 152 && Random().nextInt(100) > 98){
      var id = Random().nextInt(3)+1;
      grass = Sprite("enviroment/floor${id}.png", width: size.toDouble(), height: size.toDouble());
    }

    if (heightLvl < 50) {
      return Colors.blue[700];
    } else if (heightLvl < 75) {
      return Colors.blue[600];
    } else if (heightLvl < WATER) {
      return Colors.blue;
    } else if (heightLvl < LOW_WATER) {
      return Colors.blue[400];
    } else if (heightLvl < LOW_SAND) {
      return Color.fromRGBO(255, 224, 130, .94);
    } else if (heightLvl < SAND) {
      return Colors.amber[200];
    } else if (heightLvl < LOW_GRASS) {
      if(Random().nextInt(100) > 95){
        var id = Random().nextInt(4)+7;
        grass = Sprite("enviroment/grass${id}.png", width: size.toDouble(), height: size.toDouble());
      }
      return Color.fromRGBO(116, green+50, 54, 1);
    } else if (heightLvl < 160) {
      if(Random().nextInt(100) > 96){
        var id = Random().nextInt(2)+11;
        grass = Sprite("enviroment/grass${id}.png", width: size.toDouble(), height: size.toDouble());
      }
      return Color.fromRGBO(82, green+40, 46, 1);
    } else if (heightLvl < 185) {
      if(Random().nextInt(100) > 98){
        var id = Random().nextInt(2)+13;
        grass = Sprite("enviroment/grass${id}.png", width: size.toDouble(), height: size.toDouble());
      }
      return Color.fromRGBO(75, green+36, 65, 1);
    } else if (heightLvl < 195) {
      return Color.fromRGBO(82, green, 46, 1);
    } else {
      return Color.fromRGBO(
          heightLvl - 130, heightLvl - 130, heightLvl - 130, 1);
    }
  }

  
}
