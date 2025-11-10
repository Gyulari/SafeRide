class Device {
  final int dNumber;
  final double dLat;
  final double dLng;
  final int battery;
  final int expectedUsage;
  final int price;

  Device({
    required this.dNumber,
    required this.dLat,
    required this.dLng,
    required this.battery,
    required this.expectedUsage,
    required this.price,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      dNumber: map['device_number'],
      dLat: map['lat'],
      dLng: map['lng'],
      battery: map['battery'],
      expectedUsage: map['expected_usage'],
      price: map['price'],
    );
  }
}