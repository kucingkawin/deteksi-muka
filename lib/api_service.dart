import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';

class ApiService
{
  // Test
  final String endPoint = "http://www.facexapi.com/get_image_attr?face_det=1";

  Future<List<HasilDeteksiMuka>> deteksiMuka(List<int> bytesGambar) async
  {
    try
    {
      Dio dio = Dio(
        BaseOptions(
          baseUrl: endPoint,
          connectTimeout: 5000,
          receiveTimeout: 3000
        )
      );
      
      Response response = await dio.post("", 
        data: FormData.from({
          'image_attr': base64Encode(bytesGambar)
        }),
        options: Options(
          headers: <String, dynamic> {
            'user_id': '16fe89b6a44630aa83fc',
            'user_key': 'b05cef2e0968464f56e2'
          }
        )
      );

      print('output data: ' + response.data.toString());

      return HasilDeteksiMuka.dariJson(response.data);

    } on DioError catch(e) {
      print('Tipe error ${e.type.toString()}');
      throw e;
    }
  }
}

class HasilDeteksiMuka
{
  String _umur;
  String _gender;
  double _peluangGender;

  String get umur => _umur;
  String get gender => _gender;
  double get peluangGender => _peluangGender;
  double get persentasePeluangGender => _peluangGender * 100.0;

  set umur(String value) => _umur = value;
  set gender(String value) => _gender = value == "male" ? "laki-laki" : (value == "female" ? "perempuan" : value);
  set peluangGender(double value) => _peluangGender = value;

  HasilDeteksiMuka(String umur, String gender, double peluangGender)
  {
    this.umur = umur;
    this.gender = gender;
    this.peluangGender = peluangGender;
  }

  static List<HasilDeteksiMuka> dariJson(dynamic responseJson)
  {
    List<HasilDeteksiMuka> daftarHasilDeteksiMuka = List<HasilDeteksiMuka>();
    responseJson.forEach((String key, dynamic value){
      if(key.indexOf('face_id') > -1)
        daftarHasilDeteksiMuka.add(HasilDeteksiMuka(value['age'], value['gender'], double.parse(value['gender_confidence'])));
    });

    return daftarHasilDeteksiMuka;
  }

  @override
  String toString() {
    return 'Umur: ' + _umur + '\r\n' + 'Gender: ' + _gender.toString() + '\r\n' + 'Peluang Gender: ' + _peluangGender.toString() + ' (' + persentasePeluangGender.toString() + ')';
  }
}