import 'package:flutter/cupertino.dart';
import 'package:saferide/driving.dart';
import 'package:saferide/provider.dart';
import 'package:saferide/map.dart';

class MapIntegrated extends StatelessWidget {
  final RentalState rentalState;

  const MapIntegrated({required this.rentalState, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(rentalState.isRiding)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DrivingStatusBar(rentalState: rentalState),
          ),

        Expanded(
          child: MapView(),
        )
      ],
    );
  }
}