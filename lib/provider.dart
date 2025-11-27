import 'package:saferide/app_import.dart';

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
  DateTime? rentalStartTime;

  void startRental(int deviceNumber, int battery) {
    isRiding = true;
    this.deviceNumber = deviceNumber;
    this.battery = battery;
    rentalStartTime = DateTime.now();
    notifyListeners();
  }

  void endRental() {
    isRiding = false;
    deviceNumber = 0;
    battery = 0;
    rentalStartTime = null;
    notifyListeners();
  }
}