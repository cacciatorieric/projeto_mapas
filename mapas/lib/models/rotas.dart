import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Rotas {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Rotas({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDuration,
    required this.totalDistance,
  });

  factory Rotas.fromMap(Map<String, dynamic> map) {
    // Checar se a rota não está disponível (Não funciona mais pq o nullcheck obriga o que o resultado exista)
    //  if ((map['routas'] as List).isEmpty) return null!;

    // Pegar informações da rota
    final data = Map<String, dynamic>.from(map['routes'][0]);

    //Limites
    final nordeste = data['bounds']['northeast'];
    final sudoeste = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(sudoeste['lat'], sudoeste['lng']),
      northeast: LatLng(nordeste['lat'], nordeste['lng']),
    );

    // Distância e Duração
    String distance = '';
    String duration = '';

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Rotas(
      bounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDuration: duration,
      totalDistance: distance,
    );
  }
}
