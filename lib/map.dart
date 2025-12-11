import 'package:flutter/foundation.dart';
import 'package:saferide/app_import.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:saferide/device.dart';
import 'package:saferide/style.dart';
import 'package:saferide/rental.dart';
import 'package:saferide/provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late KakaoMapController mapController;

  StreamSubscription<Position>? _positionStream;
  bool _isGPSActive = false;

  bool isRiding = false;

  final _searchC = TextEditingController();

  LatLng curCenter = LatLng(37.5665, 126.9780);
  LatLng? curUserPos;
  bool _hasCenteredToUser = false;

  Set<Marker> deviceMarkers = {};
  Set<Marker> curPosMarker = {};
  Set<Marker> destinationMarker = {};
  Set<Marker> markers = {};
  Set<CustomOverlay> overlays = {};

  Device? selectedDevice;
  LatLng? selectedLatLng;

  bool _deviceInfoLoading = false;

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

  Future<void> _loadDeviceMarkers(LatLngBounds bounds, bool isRiding) async {
    if(isRiding) return;

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
      deviceMarkers = markersList.toSet();
      markers = {...deviceMarkers, ...curPosMarker};
    });
  }

  Future<void> _loadDeviceBatteryInfo(LatLngBounds bounds, bool isRiding) async {
    if(isRiding) return;

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

  double _calculateDistance(
      double uLat, double uLng,
      double dLat, double dLng,
  )
  {
    return Geolocator.distanceBetween(
      uLat,
      uLng,
      dLat,
      dLng,
    );
  }

  void _startListeningLocation()  async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!mounted) return;

    if(!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activate GPS on options first')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        throw Exception('Denied GPS permission');
      }
    }

    if(permission == LocationPermission.deniedForever) {
      throw Exception('GPS Permission is denied permanently.');
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        curUserPos = LatLng(position.latitude, position.longitude);
      });

      _updateCurrentUserPosition(position);

      if(!_hasCenteredToUser) {
        mapController.setCenter(
          LatLng(position.latitude, position.longitude)
        );

        _hasCenteredToUser = true;
      }
    });

    setState(() {
      _isGPSActive = true;
    });
  }

  void _stopListeningLocation() {
    _positionStream?.cancel();
    _positionStream = null;

    _isGPSActive = false;
    curUserPos = null;
  }

  void _updateCurrentUserPosition(Position pos) async {
    final latLng = LatLng(pos.latitude, pos.longitude);

    mapController.setCenter(latLng);

    final icon = await MarkerIcon.fromAsset('assets/icons/user_icon_pos.png');

    setState(() {
      final curPos = Marker(
        markerId: 'userDot_${DateTime.now().millisecondsSinceEpoch}',
        latLng: latLng,
        icon: icon,
        width: 48,
        height: 48,
      );

      curPosMarker.clear();
      curPosMarker.add(curPos);
      markers = {...deviceMarkers, ...curPosMarker};
    });
  }

  void _toggleGPS() {
    if(_isGPSActive) {
      _stopListeningLocation();
      _removeCurPosMarker();

      setState(() {
        _hasCenteredToUser = false;
      });
    } else {
      _startListeningLocation();
    }
  }

  void _removeCurPosMarker() async {
    setState(() {
      curPosMarker.clear();
      markers = {...deviceMarkers};
    });

    mapController.clearMarker(markerIds: markers.map((e) => e.markerId).toList());
  }

  Future<void> _showDeviceInfoDialog(
    BuildContext context, {
    required Device device,
    required double? distance,
    VoidCallback? onRent,
    VoidCallback? onClose,
    bool barrierDismissible = false,
  })
  {
    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'DeviceInfo',
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return Center(
          child: DeviceInfoDialog(
            device: device,
            distance: distance,
            onRent: onRent,
            onClose: onClose,
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _stopListeningLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rentalState = Provider.of<RentalState>(context);

    return Stack(
      children: [
        KakaoMap(
          onMapCreated: ((controller) async {
            mapController = controller;
            final bounds = await mapController.getBounds();
            await _loadDeviceMarkers(bounds, rentalState.isRiding);
            await _loadDeviceBatteryInfo(bounds, rentalState.isRiding);
          }),
          onCameraIdle: (LatLng center, int zoomLevel) {
            mapController.getBounds().then((bounds) {
              _loadDeviceMarkers(bounds, rentalState.isRiding);
              _loadDeviceBatteryInfo(bounds, rentalState.isRiding);
            });
          },
          center: curCenter,
          currentLevel: 3,
          zoomControl: true,
          zoomControlPosition: ControlPosition.bottomRight,
          markers: markers.toList(),
          onMarkerTap: (markerId, latLng, level) async {
            if(_deviceInfoLoading) return;

            setState(() {
              _deviceInfoLoading = true;
            });

            final device = await _getDeviceByMarkerId(markerId);

            if(!context.mounted || device == null) return;

            double? distance;
            if(curUserPos != null) {
              distance = _calculateDistance(curUserPos!.latitude, curUserPos!.longitude, device.dLat, device.dLng);
            } else {
              distance = null;
            }

            _showDeviceInfoDialog(
              context,
              device: device,
              distance: distance,
              onRent: () {

              },
              onClose: () {
                setState(() {
                  _deviceInfoLoading = false;
                });
              }
            );

            setState(() {
              selectedDevice = device;
              selectedLatLng = latLng;
            });
          },
          customOverlays: overlays.toList(),
        ),

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

        Positioned(
          top: 75.0,
          right: 16.0,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _toggleGPS,
            child: Icon(
              _isGPSActive ? Icons.gps_fixed : Icons.gps_off,
              color: _isGPSActive ? Colors.blueAccent : Colors.grey,
            ),
          )
        ),

        if(rentalState.isSelectingDestination)
          Center(
            child: Icon(Icons.location_on, size: 48.0, color: Colors.red),
          ),

        if(rentalState.isSelectingDestination)
          Positioned(
            bottom: 40.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () async {
                isRiding = true;
                final center = await mapController.getCenter();

                rentalState.setDestination(center);

                final icon = await MarkerIcon.fromAsset('assets/icons/destination_icon_pos.png');
                final destinationPos = Marker(
                  markerId: 'destination',
                  latLng: center,
                  icon: icon,
                  width: 48,
                  height: 48,
                );

                destinationMarker.add(destinationPos);
                markers = {...destinationMarker, ...curPosMarker};

                if(!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('목적지가 설정되었습니다.')),
                );
              },
              child: simpleText(
                '목적지 설정',
                18.0, FontWeight.bold, Colors.white, TextAlign.center
              ),
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
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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

class DeviceInfoDialog extends StatelessWidget {
  final Device device;
  final double? distance;
  final VoidCallback? onRent;
  final VoidCallback? onClose;

  const DeviceInfoDialog({
    super.key,
    required this.device,
    required this.distance,
    this.onRent,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
          width: 360.0,
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(color: Colors.black26,
                  blurRadius: 18.0,
                  offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Row(
                  children: [
                    simpleText(
                        '킥보드 정보',
                        16.0, FontWeight.bold, Colors.black, TextAlign.start
                    ),

                    Spacer(),

                    InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      onTap: () {
                        Navigator.of(context).maybePop();
                        onClose?.call();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close, size: 20.0, color: Colors.black,),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 96.0,
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE6F1FF), Color(0xFFE7F8ED)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.bolt, size: 48.0, color: Color(0xFF1E88E5)),
                ),
              ),

              SizedBox(height: 8.0),

              DeviceInfoRow(
                icon: Icons.battery_full_rounded,
                label: '배터리 잔량',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 120.0,
                      height: 8.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: LinearProgressIndicator(
                          value: (device.battery.clamp(0, 100)) / 100.0,
                          backgroundColor: Color(0xFFE9EEF5),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    simpleText(
                        '${device.battery}%',
                        12.0, FontWeight.normal, Colors.black, TextAlign.start
                    ),
                  ],
                ),
              ),

              divider(),

              DeviceInfoRow(
                icon: Icons.access_time_filled_rounded,
                label: '예상 이용 시간',
                trailingText: '${device.expectedUsage}분',
              ),

              divider(),

              DeviceInfoRow(
                  icon: Icons.attach_money_rounded,
                  label: '기본 요금',
                  trailingText: '₩${device.price}/분'
              ),

              divider(),

              DeviceInfoRow(
                icon: Icons.place_rounded,
                label: '거리',
                trailingText: distance == null ? '- m' : '${(distance! / 1000 * 100).floorToDouble()/100}km',
              ),

              SizedBox(height: 16.0),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RentalScreen(device: device),
                        )
                      );
                    },
                    child: simpleText(
                      '대여하기',
                      16.0, FontWeight.bold, Colors.white, TextAlign.center
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}

class DeviceInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final Widget? trailing;

  const DeviceInfoRow(
  {
    super.key,
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Colors.black),
          SizedBox(width: 10.0),
          Expanded(
            child: simpleText(
              label,
              12.0, FontWeight.normal, Colors.black, TextAlign.start
            ),
          ),

          if(trailing != null)
            trailing!,

          if(trailingText != null) ...[
            simpleText(
              trailingText!,
              12.0, FontWeight.normal, Colors.black, TextAlign.start
            ),
          ]
        ],
      )
    );
  }
}