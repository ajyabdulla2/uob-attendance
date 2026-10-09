import 'package:flutter/material.dart';

import '../../../core/widgets/common_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: CenteredBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [UniversityHeader(), SizedBox(height: 32), CircularProgressIndicator()],
          ),
        ),
      );
}
