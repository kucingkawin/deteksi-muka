import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/api_service.dart';


class DeteksiGambar extends StatefulWidget {
  DeteksiGambar({Key key, this.bytesFoto}) : super(key: key);

  static String route = 'deteksi-gambar';

  // Argument
  List<int> bytesFoto;

  @override
  _DeteksiGambarState createState() => _DeteksiGambarState();
}

class _DeteksiGambarState extends State<DeteksiGambar> {

  Future<List<HasilDeteksiMuka>> _futureHasilDeteksiGambar;
  Future<Uint8List> _futureBytesGambar;
  ApiService _apiService;

  void _prosesDeteksiGambar()
  {
    _futureHasilDeteksiGambar = _apiService.deteksiMuka(widget.bytesFoto);
    _futureBytesGambar = _tampilkanGambar();
  }

  Future<Uint8List> _tampilkanGambar() async
  {
    Uint8List bytesGambar = await Uint8List.fromList(widget.bytesFoto);
    return bytesGambar;
  }

  @override
  void initState()
  {
    _apiService = ApiService();
    _prosesDeteksiGambar();
  }

  FutureBuilder<List<HasilDeteksiMuka>> _buatFutureHasilDeteksiGambar()
  {
    return FutureBuilder(
      future: _futureHasilDeteksiGambar,
      builder: (BuildContext context, AsyncSnapshot<List<HasilDeteksiMuka>> snapshot) {
        print(snapshot.connectionState);
        print("Data ada: ${snapshot.hasData} (Error: ${snapshot.hasError})");
        if(snapshot.connectionState == ConnectionState.done){

          //Dapatkan data terlebih dahulu
          List<HasilDeteksiMuka> hasilDeteksiMuka = snapshot.data;

          //Buat widgetnya (pertama buat image dulu)
          List<Widget> widgetHasilDeteksiGambar = <Widget>[
            FutureBuilder(
              future: _futureBytesGambar,
              builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  if(!snapshot.hasError) {
                    return Column(
                      children: <Widget>[
                        Image.memory(snapshot.data, fit: BoxFit.fitWidth),
                        SizedBox(height: 10.0),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    );
                  }
                }
                else if(snapshot.connectionState == ConnectionState.waiting)
                {
                  return Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 10.0),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  );
                }
                else
                  return null;
              }
            ),
          ];

          //Lakukan sebuah perulangan
          hasilDeteksiMuka.forEach((HasilDeteksiMuka data){
            widgetHasilDeteksiGambar.addAll(<Widget>[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text('Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data.gender}'),
                      SizedBox(height: 10.0),
                      Text('Umur:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data.umur}'),
                      SizedBox(height: 10.0),
                      Text('Peluang Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data.peluangGender}'),
                      SizedBox(height: 10.0),
                      Text('Persentase Peluang Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${data.persentasePeluangGender} %'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
              )
            ]);
          });

          return Column(
            children: widgetHasilDeteksiGambar,
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        }
        else if(snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: <Widget>[
              SizedBox(height: 50.0),
              CircularProgressIndicator()
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          );
        }
        else if(snapshot.hasError) {
          return Text('Ada permasalahan di bagian loadnya');
        }
        else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Hasil Deteksi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buatFutureHasilDeteksiGambar()
        ],
      ),
    );
  }
}
