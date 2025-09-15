
import 'package:flutter/material.dart';

import '../widgets/navbar_widget.dart';

class ServiceView extends StatelessWidget {

  const ServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Center(
      child: Text("Service View"),
    );
  }
}