import 'package:exif/exif.dart';
import 'dart:io';
import 'dart:convert';

Future<String> getExifFromFile(File _image) async {
if (_image == null) {
  return null;
}

var bytes = await _image.readAsBytes();
var tags = await readExifFromBytes(bytes);
if (tags.isEmpty){
  print("exif yok");
  return null;
}

var sb = StringBuffer();

sb.write("{");
tags.forEach((k, v) {
  sb.write('"$k": "$v", \n');
});
sb.write('"Sndt": "as"}');
String toStringed = sb.toString();
var parsedJson= json.decode(toStringed);
print('${parsedJson.runtimeType} : $parsedJson');
final gpsLatRef = parsedJson['GPS GPSLatitudeRef'];
final gpsLongRef = parsedJson['GPS GPSLongitudeRef'];
final gpsLat = parsedJson['GPS GPSLatitude'];
final gpsLong= parsedJson['GPS GPSLongitude'];
//latitutde cevirme
var removedBracketsLat = "[";
removedBracketsLat = gpsLat.substring(1, gpsLat.length - 1);
final partsLat = removedBracketsLat.split(', ');
var joinedLat = partsLat.map((part) => '"$part"').join(',');
var listLat = [joinedLat].toString();
print(listLat);
var latList = json.decode(listLat);
double latFirst = double.tryParse(latList[0]);
double latSecond = double.tryParse(latList[1]);
double latitude = latFirst
  + (latSecond / 60);

//longtitud
var removedBracketsLong = "[";
removedBracketsLong = gpsLong.substring(1, gpsLong.length - 1);
final partsLong = removedBracketsLong.split(', ');
var joinedLong = partsLong.map((part) => '"$part"').join(',');
var listLong = [joinedLong].toString();
print(listLong);
var longList = json.decode(listLong);
double longFirst = double.tryParse(longList[0]);
double longSecond = double.tryParse(longList[1]);
double longtitude = longFirst
+ (longSecond / 60);
if (gpsLatRef == 'S') latitude = -latitude;
if (gpsLongRef== 'W') longtitude = -longtitude;
//print(latitude);
//print(longtitude);
dynamic fullCoordinate= '["' + latitude.toString() + '",' + longtitude.toString() + ']';
print(fullCoordinate);
return fullCoordinate;
}