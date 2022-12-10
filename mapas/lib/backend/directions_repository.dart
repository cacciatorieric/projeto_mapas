import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas/.keys/.env.dart';
import 'package:mapas/models/rotas.dart';

class RepositorioDeRotas {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  Dio? _dio;
  RepositorioDeRotas({Dio? dio}) : _dio = dio ?? Dio();

  Future<Rotas> pegarRotas(
      {required LatLng origem, required LatLng destino}) async {
    try {
      final resposta = await _dio!.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origem.latitude},${origem.longitude}',
          'destination': '${destino.latitude},${destino.longitude}',
          'key': googleApiKey,
        },
      );
      // Confirmar se a resposta chegou com sucesso no servidor
      if (resposta.statusCode == 200) {
        return Rotas.fromMap(resposta.data);
      }
    } catch (erro) {
      print('Tá aqui o filho da puta $erro');
    }

    return null!;
  }
}
