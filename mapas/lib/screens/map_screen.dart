import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas/backend/directions_repository.dart';
import 'package:mapas/models/rotas.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  Marker? _origemDoMarcador;
  Marker? _destinoDoMarcador;
  Rotas? _info;

  static const _posicaoInicialDaCamera = CameraPosition(
      target: LatLng(
        -23.470649,
        -46.553726,
      ),
      zoom: 15.5,
      tilt: 40);

  void _addMarcador(LatLng argumentoLatLng) async {
    if (_origemDoMarcador == null ||
        (_origemDoMarcador != null && _destinoDoMarcador != null)) {
      // Se a origem ainda NÃO estiver definida ou se a origem e destino JÁ estiverem definidos
      // Vamos definir a ORIGEM
      setState(() {
        _origemDoMarcador = Marker(
          markerId: const MarkerId('origem'),
          infoWindow: const InfoWindow(title: "Marcador de Origem "),
          position: argumentoLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
        // Resetar Destino
        _destinoDoMarcador = null;
        // Resetar Info
        _info = null;
      });
    } else {
      // Como nesse estado, a origem já está definida, então aqui vamos definir o DESTINO

      setState(
        () {
          _destinoDoMarcador = Marker(
            markerId: const MarkerId('destino'),
            infoWindow: const InfoWindow(title: "Marcador de Destino "),
            position: argumentoLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          );
        },
      );

      final rotas = await RepositorioDeRotas().pegarRotas(
        origem: _origemDoMarcador!.position,
        destino: argumentoLatLng,
      );
      setState(() {
        _info = rotas;
      });
    }
  }

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelo de Mapas'),
        centerTitle: false,
        actions: [
          if (_origemDoMarcador != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origemDoMarcador!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              child: const Text('Ir para Origem'),
            ),
          TextButton(
            onPressed: () => _googleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _destinoDoMarcador!.position,
                  zoom: 14.5,
                  tilt: 50.0,
                ),
              ),
            ),
            child: const Text('Ir para o Destino'),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _posicaoInicialDaCamera,
            onMapCreated: (controller) => _googleMapController = controller,
            polylines: {
              if (_info != null)
                Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((rota) => LatLng(rota.latitude, rota.longitude))
                        .toList()),
            },
            markers: {
              if (_origemDoMarcador != null) _origemDoMarcador!,
              if (_destinoDoMarcador != null) _destinoDoMarcador!,
            },
            onLongPress: _addMarcador,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12,
                ),
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController!.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.00)
              : CameraUpdate.newCameraPosition(_posicaoInicialDaCamera),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
