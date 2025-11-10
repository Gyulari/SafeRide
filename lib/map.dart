import 'package:saferide/app_import.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:saferide/device.dart';
import 'package:saferide/style.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late KakaoMapController mapController;

  final _searchC = TextEditingController();

  LatLng curCenter = LatLng(37.5665, 126.9780);

  Set<Marker> markers = {};
  Set<CustomOverlay> overlays = {};

  Device? selectedDevice;
  LatLng? selectedLatLng;

  Future<List<LatLng>> _keywordSearch(String keyword) async {
    const apiKey = '5d85b804b65d01a8faf7acb5d95d8c76';
    final url = Uri.parse(
      'https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword',
    );

    final res = await http.get(url, headers: {
      'Authorization': 'KakaoAK $apiKey',
    });

    if(res.statusCode == 200){
      final data = jsonDecode(res.body);
      final List docs = data['documents'];

      return docs.map((doc) {
        final x = double.parse(doc['x']);
        final y = double.parse(doc['y']);
        return LatLng(y, x);
      }).toList();
    } else {
      throw Exception('검색 실패: ${res.statusCode}');
    }
  }

  Future<void> _loadDeviceMarkers(LatLngBounds bounds) async {
    final deviceData = await fetchDevicesInBounds(bounds);

    final markersListAsync = deviceData.map((device) async {
      final latLng = LatLng(device.dLat, device.dLng);
      String iconPath = '';

      if(device.battery > 80) {
        iconPath = 'assets/icons/device_icon_green.png';
      } else if (device.battery > 30){
        iconPath = 'assets/icons/device_icon_yellow.png';
      } else {
        iconPath = 'assets/icons/device_icon_red.png';
      }

      return Marker(
        markerId: device.dNumber.toString(),
        latLng: latLng,
        icon: await MarkerIcon.fromAsset(iconPath),
        width: 48,
        height: 48,
      );
    }).toList();

    final markersList = await Future.wait(markersListAsync);

    setState(() {
      markers = markersList.toSet();
    });
  }

  Future<void> _loadDeviceBatteryInfo(LatLngBounds bounds) async {
    final deviceData = await fetchDevicesInBounds(bounds);

    final overlaysListAsync = deviceData.map((device) async {
      final latLng = LatLng(device.dLat, device.dLng);

      return CustomOverlay(
        customOverlayId: device.dNumber.toString(),
        latLng: latLng,
        content: '<div style="width: 24px; height: 24px; background-color: white; border-radius: 50%; border: 2px solid #ccc; display: flex; align-items:center; justify-content: center; font-weight: bold; color: black; font-size: 10px; box-shadow: 0px 1px 3px rgba(0,0,0,0.3);">${device.battery}%</div>',
        xAnchor: -0.25,
        yAnchor: 1.75,
      );
    }).toList();

    final overlaysList = await Future.wait(overlaysListAsync);

    setState(() {
      overlays = overlaysList.toSet();
    });
  }

  Future<List<Device>> fetchDevicesInBounds(LatLngBounds bounds) async {
    final res = await SupabaseManager.client
        .from('devices')
        .select('*')
        .gte('lat', bounds.getSouthWest().latitude)
        .lte('lat', bounds.getNorthEast().latitude)
        .gte('lng', bounds.getSouthWest().longitude)
        .lte('lng', bounds.getNorthEast().longitude);

    return (res as List).map((e) => Device.fromMap(e)).toList();
  }

  Future<Device?> _getDeviceByMarkerId(String markerId) async {
    final res = await SupabaseManager.client
        .from('devices')
        .select('*')
        .eq('device_number', int.parse(markerId))
        .maybeSingle();

    if(res == null) return null;
    return Device.fromMap(res);
  }

  Widget _deviceInfoPopup(BuildContext context) {
    final device = selectedDevice;

    return Positioned(
      bottom: 100.0,
      left: 20.0,
      right: 20.0,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              simpleText(
                '배터리 잔량: ${device!.battery}%',
                18.0, FontWeight.bold, Colors.black, TextAlign.start
              ),
              SizedBox(height: 6.0),
              simpleText(
                '예상 사용 시간: ${device.expectedUsage}분',
                18.0, FontWeight.bold, Colors.black, TextAlign.start
              ),
              SizedBox(height: 6.0),
              simpleText(
                  '가격: 1분 당 ${device.price}원',
                  18.0, FontWeight.bold, Colors.black, TextAlign.start
              ),
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedDevice = null;
                      selectedLatLng = null;
                    });
                  },
                  child: Text('닫기'),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KakaoMap(
          onMapCreated: ((controller) async {
            mapController = controller;
            final bounds = await mapController.getBounds();
            await _loadDeviceMarkers(bounds);
            await _loadDeviceBatteryInfo(bounds);
          }),
          onCameraIdle: (LatLng center, int zoomLevel) {
            mapController.getBounds().then((bounds) {
              _loadDeviceMarkers(bounds);
              _loadDeviceBatteryInfo(bounds);
            });
          },
          center: curCenter,
          currentLevel: 3,
          zoomControl: true,
          zoomControlPosition: ControlPosition.bottomRight,
          markers: markers.toList(),
          onMarkerTap: (markerId, latLng, level) async {
            final device = await _getDeviceByMarkerId(markerId);
            setState(() {
              selectedDevice = device;
              selectedLatLng = latLng;
            });
          },
          customOverlays: overlays.toList(),
        ),

        if(selectedDevice != null && selectedLatLng != null)
          _deviceInfoPopup(context),

        SafeArea(
          child: MapSearchBar(
            controller: _searchC,
            onSearch: (keyword) async {
              final results = await _keywordSearch(keyword);

              if(results.isEmpty) return;

              setState(() {
                markers = results
                    .map((pos) => Marker(
                        markerId: UniqueKey().toString(),
                        latLng: pos,
                )).toSet();
              });

              mapController.fitBounds(results);
            },
          ),
        ),
      ],
    );
  }
}

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onSearch;

  const MapSearchBar({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: '장소를 검색하세요',
          hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
      ),
    );
  }
}