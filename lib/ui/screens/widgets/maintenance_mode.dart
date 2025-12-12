import 'package:BidNBuy/ui/theme/theme.dart';
import 'package:BidNBuy/utils/extensions/extensions.dart';
import 'package:BidNBuy/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:BidNBuy/ui/screens/widgets/animated_routes/blur_page_route.dart';

class MaintenanceMode extends StatelessWidget {
  const MaintenanceMode({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const MaintenanceMode();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottie/${Constant.maintenanceModeLottieFile}",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
                    "maintenanceModeMessage".translate(context),
                    textAlign: TextAlign.center)
                .color(context.color.textColorDark),
          )
        ],
      ),
    );
  }
}
