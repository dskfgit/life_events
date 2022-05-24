//import 'dart:async';
//import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_icons/flutter_icons.dart';

class LifeEvent {
  final int id;
  final String theDay;
  final String name;
  final String details;
  final int type;
  final int related;

  static const int typeBday = 0;
  static const int typeDeath = 1;
  static const int typeWork = 2;
  static const int typePersonal = 3;
  static const int typePurchase = 4;
  static const int typeAll = 1000;

  LifeEvent(
      {this.id, this.name, this.theDay, this.details, this.type, this.related});

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'theDay': theDay,
      'details': details,
      'type': type,
      'related': related,
    };
  }

  LifeEvent fromMap(Map<String, dynamic> aMap) {
    return LifeEvent(
        id: aMap[DatabaseHelper.columnId],
        name: aMap[DatabaseHelper.columnName],
        theDay: aMap[DatabaseHelper.columnTheDay],
        details: aMap[DatabaseHelper.columnDetails],
        type: aMap[DatabaseHelper.columnType],
        related: aMap[DatabaseHelper.columnRelated]);
  }

  static IconData getTypeIcon(int type) {
    IconData iconData;
    switch (type) {
      case typeDeath:
        {
          iconData = FlutterIcons.skull_outline_mco;
              //Icons.hourglass_bottom_outlined;
        }
        break;
      case typeBday:
        {
          iconData = FlutterIcons.baby_face_outline_mco;
          //Icons.child_friendly_outlined;
        }
        break;
      case typeWork:
        {
          iconData = FlutterIcons.briefcase_outline_mco;
              //Icons.work_outline_outlined;
        }
        break;
      case typePersonal:
        {
          iconData = FlutterIcons.heart_circle_outline_mco;
              //Icons.account_circle_outlined;
        }
        break;
      case typePurchase:
        {
          iconData = FlutterIcons.cart_outline_mco;
          //Icons.monetization_on_outlined;
        }
        break;
      case typeAll:
        {
          iconData = Icons.clear_all;
        }
        break;
    }
    return iconData;
  }

  String padDayMonth(int dayOrMonth) {
    if (dayOrMonth < 10) {
      return "0" + dayOrMonth.toString();
    } else {
      return dayOrMonth.toString();
    }
  }

  String getFormattedDate() {
    String aDate = '';
    //Format the date string in the database for DD/MM/YYYY
    DateTime dt = DateFormat("yyyy-MM-dd hh:mm").parse(theDay);
    aDate = padDayMonth(dt.day) +
        '/' +
        padDayMonth(dt.month) +
        '/' +
        dt.year.toString();
    return aDate;
  }

  String getMonth() {
    //Format the date string in the database for DD/MM/YYYY
    DateTime dt = DateFormat("yyyy-MM-dd hh:mm").parse(theDay);
    return dt.month.toString();
  }

  String getDay() {
    //Format the date string in the database for DD/MM/YYYY
    DateTime dt = DateFormat("yyyy-MM-dd hh:mm").parse(theDay);
    return dt.day.toString();
  }
}
