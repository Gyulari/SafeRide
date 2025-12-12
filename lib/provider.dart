import 'package:saferide/app_import.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class NavState extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

class UserInfoState extends ChangeNotifier {
  String userName = '';
  String userEmail = '';

  Future<void> fetchUserInfo() async {
    final user = SupabaseManager.client.auth.currentUser;
    if(user == null) return;

    final res = await SupabaseManager.client
        .from('profiles')
        .select('name')
        .eq('id', user.id)
        .maybeSingle();

    if(res == null) return;

    userName = res['name'];
    userEmail = user.email!;

    notifyListeners();
  }
}

class RentalState extends ChangeNotifier {
  bool isRiding = false;
  bool isCouple = false;

  int deviceNumber = 0;
  int battery = 0;
  int charge = 0;
  DateTime? rentalStartTime;

  bool isSelectingDestination = false;
  LatLng? destination;
  List<LatLng> routePath = [];

  LatLng? previousPosition;
  LatLng? currentPosition;
  StreamSubscription<Position>? _positionsStream;
  void Function(Position, bool)? _onLocationChanged;

  void registerLocationUpdateCallback(void Function(Position, bool) callback) {
    _onLocationChanged = callback;
  }

  void startDestinationSelection(int deviceNumber, int battery, int charge, bool isCouple) {
    isSelectingDestination = true;
    isRiding = false;
    destination = null;
    routePath.clear();
    this.deviceNumber = deviceNumber;
    this.battery = battery;
    this.charge = charge;
    this.isCouple = isCouple;
    notifyListeners();
  }

  void setDestination(LatLng dest) {
    destination = dest;
    isSelectingDestination = false;
    rentalStartTime = DateTime.now();
    startRiding();
  }

  void startRiding() {
    isRiding = true;
    _startGPS();
    notifyListeners();
  }

  void addRoutePoint(LatLng point) {
    routePath.add(point);
    notifyListeners();
  }

  void endRental() {
    isRiding = false;
    isSelectingDestination = false;
    destination = null;
    routePath.clear();
    deviceNumber = 0;
    battery = 0;
    charge = 0;
    rentalStartTime = null;
    isCouple = false;
    _stopGPS();
    clearRouteTracking();
    notifyListeners();
  }

  void _startGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) return;
    }

    _positionsStream?.cancel();

    _positionsStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      currentPosition = LatLng(pos.latitude, pos.longitude);

      if(_onLocationChanged != null) {
        _onLocationChanged!(pos, true);
      }

      updatePosition(pos);

      notifyListeners();
    });
  }

  void _stopGPS() {
    _positionsStream?.cancel();
    _positionsStream = null;
  }

  void updatePosition(Position newPos) {
    if(previousPosition != null) {
      routePath.add(previousPosition!);
      routePath.add(LatLng(newPos.latitude, newPos.longitude));
    }

    debugPrint('Previous : $previousPosition');
    debugPrint('New : $newPos');

    previousPosition = LatLng(newPos.latitude, newPos.longitude);

    notifyListeners();
  }

  void clearRouteTracking() {
    previousPosition = null;
    routePath.clear();
    notifyListeners();
  }
}