import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:face_recognition/deteksi_gambar.dart';

class InputFace extends StatefulWidget {
  InputFace({Key key, this.title}) : super(key: key);

  static String route = 'input-face';

  final String title;

  @override
  _InputFaceState createState() => _InputFaceState();
}

class _InputFaceState extends State<InputFace> {

  Future<Uint8List> _futureFotoBytes;
  Uint8List _hasilFotoBytes;

  void _bukaFoto() async
  {
    File foto = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(foto != null)
    {
      setState((){
        _futureFotoBytes = _bacaFoto(foto);
      });
    }
  }

  Future<Uint8List> _bacaFoto(File foto) async
  {
    if(foto == null)
    {
      print('Tidak ada file yang ingin diolah');
      return null;
    }
    else
    {
      List<int> bytes = await foto.readAsBytes();
      Uint8List list = Uint8List.fromList(bytes);

      return list;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text('Silakan mencari gambar sebagai input fotonya.'),
          SizedBox(height: 10.0),
          FlatButton(
            child: Text('Cari Gambar'),
            onPressed: () => _bukaFoto(),
            color: Colors.orange[600],
            textColor: Colors.white,
          ),
          SizedBox(height: 10.0),
          Text('Foto:', style: TextStyle(fontWeight: FontWeight.bold)),
          FutureBuilder(
            future: _futureFotoBytes,
            builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
              print(snapshot.connectionState);
              if(snapshot.connectionState == ConnectionState.done){
                _hasilFotoBytes = snapshot.data;
                print('Berhasil ditambahkan gambar.');
                return Column(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Center(
                      child: Image.memory(_hasilFotoBytes, fit: BoxFit.fitWidth),
                    ),
                    SizedBox(height: 10.0),
                    FlatButton(
                      child: Text('Lakukan Deteksi Gambar'),
                      onPressed: () {
                        print('Tombol Deteksi Gambar');
                        Navigator.of(context).pushNamed(DeteksiGambar.route, arguments: _hasilFotoBytes);
                      },
                      color: Colors.red[600],
                      textColor: Colors.white,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                );
              }
              else if(snapshot.connectionState == ConnectionState.waiting)
              {
                return CircularProgressIndicator();
              }
              else if(snapshot.hasError) {
                return Text('Ada permasalahan di bagian loadnya');
              }
              else {
                return Text('Belum ada foto');
              }
            },
          ),
        ],
      ),
    );
  }
}
