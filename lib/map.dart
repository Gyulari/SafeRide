import 'package:saferide/app_import.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KakaoMap(
          onMapCreated: ((controller) async {
            mapController = controller;
            // final bounds = await mapController.getBounds();
          }),
          onCameraIdle: (LatLng center, int zoomLevel) {

          },
          center: curCenter,
          currentLevel: 3,
          zoomControl: true,
          zoomControlPosition: ControlPosition.topRight,
          markers: markers.toList(),
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