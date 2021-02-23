import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_text_boundry/controller/getMetadata.dart' as metadataController;
import 'package:image_text_boundry/controller/saver.dart' as saver;
import 'package:geocoder/geocoder.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Offset offset = Offset.zero;
  final GlobalKey globalKey = new GlobalKey();
  final GlobalKey headerTextFieldKey = new GlobalKey();

  String headerText = "";
  var _controller = TextEditingController();
  var locationString;
  Color headerTextInput;

  bool imageSelected = false;

  File _image;
  File _imageFile;

  Random rng = new Random();

  Future getImage() async {
    var image;
    try {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("izin verilmedi" + platformException);
    }
    setState(() {
      if (image != null) {
        imageSelected = true;
      } else {}
      _image = image;
    });
    new Directory('storage/emulated/0/pictures/' + 'image_text_boundry')
        .create(recursive: true);
    dynamic coordinatesGot = await metadataController.getExifFromFile(_image);
    if (coordinatesGot != null) {
      var tempCoordinate = json.decode(coordinatesGot);
      print(tempCoordinate);
      double latCoord = double.tryParse(tempCoordinate[0]);
      double longCoord = tempCoordinate[1];
      print(latCoord);
      print(longCoord);
      var addresses;
      var first;
      final coordinates = new Coordinates(latCoord, longCoord);
      addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      first = addresses.first;
      locationString = ("${first.adminArea}, ${first.countryName}");
      print("${first.adminArea}, ${first.countryName}");
      setState(() {
        locationString = locationString;
      });
      return (locationString);
    }
    setState(() {
      locationString = null;
    });
    return (null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/galleryIcon.png",
                height: 60,
              ),
              Image.asset(
                "assets/galleryText.png",
                height: 40,
              ),
              SizedBox(
                height: 10,
              ),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: <Widget>[
                    _image != null
                        ? Image.file(
                            _image,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                    Container(
                      child: Positioned(
                        left: offset.dx,
                        top: offset.dy,
                        child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                offset = Offset(offset.dx + details.delta.dx,
                                    offset.dy + details.delta.dy);
                              });
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(headerText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: headerTextInput)),
                                ),
                              ),
                            )),
                      ),
                    ),
                    locationString != null
                        ? Text(
                            locationString,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                backgroundColor: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white),
                          )
                        : Container(),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              imageSelected
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _controller,
                            key: headerTextFieldKey,
                            onChanged: (val) {
                              setState(() {
                                headerText = val;
                              });
                            },
                            decoration:
                                InputDecoration(hintText: "Yazi Ekleyin"),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          DropdownButton(
                            hint: Text("Yazi Rengi Secin"),
                            onChanged: (val) {
                              setState(() {
                                headerTextInput = val;
                              });
                            },
                          ),
                          RaisedButton(
                              onPressed: () {
                                takeScreenshot();
                              },
                              child: Text("Olustur")),
                          _imageFile != null
                              ? RaisedButton(
                                  onPressed: () {
                                    saver.shareFile(_imageFile);
                                  },
                                  child: Text("Paylas"))
                              : Container(),
                        ],
                      ),
                    )
                  : Container(
                      child: Center(
                        child: Text("Baslamak icin galeriden foto yukleyin"),
                      ),
                    ),
              _imageFile != null ? Image.file(_imageFile) : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.clear();
          getImage();
          _imageFile = null;
          headerText = "";
          setState(() {
            offset = Offset.zero;
          });
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    print(directory + "      bu getDirectory");
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    int random = rng.nextInt(200);
    String path = '/storage/emulated/0/pictures/image_text_boundry';
    File imgFile = new File('$path/screenshot$random.png');
    setState(() {
      _imageFile = imgFile;
    });
    print(_imageFile);
    saver.savefile(_imageFile);
    imgFile.writeAsBytes(pngBytes);
  }
}
