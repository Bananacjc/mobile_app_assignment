
import 'package:flutter/material.dart';
import 'package:mobile_app_assignment/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../provider/navigation_provider.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();

}

class _FeedbackViewState extends State<FeedbackView> {
  final String _title = "Feedback";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.softWhite,
      appBar: AppBarWidget(title: _title, showBackButton: true, onBackPressed: navigationProvider.goBack,),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Feedback"),
          ],
        ),
      ),

    );
  }
}