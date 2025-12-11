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

  int deviceNumber = 0;
  int battery = 0;
  int charge = 0;
  DateTime? rentalStartTime;

  bool isSelectingDestination = false;
  LatLng? destination;
  List<LatLng> routePath = [];

  void startDestinationSelection(int deviceNumber, int battery, int charge) {
    isSelectingDestination = true;
    isRiding = false;
    destination = null;
    routePath.clear();
    this.deviceNumber = deviceNumber;
    this.battery = battery;
    this.charge = charge;
    notifyListeners();
  }

  void setDestination(LatLng dest) {
    destination = dest;
    isSelectingDestination = false;
    isRiding = true;
    rentalStartTime = DateTime.now();
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
    notifyListeners();
  }
}