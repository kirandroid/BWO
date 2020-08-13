import 'dart:math';

import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../effects/damage_effect.dart';
import '../effects/ripple_water_effect.dart';
import '../effects/walk_effect.dart';
import '../scene/game_scene.dart';
import 'physics_entity.dart';
import 'player/player.dart';
import 'status.dart';

abstract class Entity extends PhysicsEntity {
  Status status = Status();
  bool marketToBeRemoved = false;
  bool isActive = true;

  String name;
  String id;

  ///tiled position
  int posX;
  int posY;

  int mapHeight = 1;
  double width = 16;
  double height = 16;

  Rect collisionBox;
  bool isCollisionTrigger = false;

  double worldSize;

  Paint p = Paint();

  double shadownSize = 2;
  Sprite shadownLarge = Sprite("shadown_large.png");
  final RippleWaterEffect _rippleWaterEffect = RippleWaterEffect();
  final WalkEffect _walkEffect = WalkEffect();
  final DamageEffect _damageEffect = DamageEffect();

  Entity(double x, double y) : super(x, y) {
    worldSize = GameScene.worldSize.toDouble();

    updatePhysics();
  }

  void draw(Canvas c) {
    print("drawning wrongly, this draw method should be overwritten.");
  }

  void update() {
    if (!isActive) {
      return;
    }
    var walkSpeed = max(inputSpeed.dx.abs(), inputSpeed.dy.abs());
    status.update(walkSpeed);
    if (status.getEnergy() <= 0) {
      maxSpeedEnergyMultiplier = .5;
    } else {
      maxSpeedEnergyMultiplier = 1;
    }
  }

  void debugDraw(Canvas c) {
    p.color = Colors.red;
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
    c.drawRect(collisionBox, p);
  }

  void drawEffects(Canvas c) {
    if (!isActive) {
      return;
    }
    _drawShadown(c);
    if (this is Player) {
      _rippleWaterEffect.draw(c, x, y, mapHeight);
      _walkEffect.draw(c, x, y, mapHeight, inputSpeed);
    }
    _damageEffect.draw(c, x, y);
  }

  void _drawShadown(Canvas c) {
    var distanceToGround = 1 - (z.abs().clamp(0, 100) / 100);
    var p = Paint();
    p.color = Color.fromRGBO(255, 255, 255, distanceToGround);

    var sizeX = 16 * shadownSize / 2;
    var sizeY = (16 - 3) * shadownSize;

    shadownLarge.renderScaled(
      c,
      Position(
        x - sizeX * distanceToGround,
        y - sizeY * distanceToGround,
      ),
      scale: shadownSize * distanceToGround,
      overridePaint: p,
    );
  }

  void updatePhysics() {
    posX = x ~/ worldSize;
    posY = y ~/ worldSize;

    collisionBox = Rect.fromLTWH(x - (width / 2), y - height, width, height);

    updateGravity();
    moveFriction();
  }

  void getHut(int damage, Entity other, {bool isMine = false}) {
    status.takeDamage(damage);
    showDamage(damage, isMine: isMine);
  }

  void showDamage(int damage, {bool isMine = false}) {
    _damageEffect.addText(damage, isMine: isMine);
  }

  void onTriggerStay(Entity entity) {}

  void destroy() {
    marketToBeRemoved = true;
  }
}
