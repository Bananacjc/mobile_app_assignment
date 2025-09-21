import 'package:flutter/material.dart';
import 'package:mobile_app_assignment/model/global_user.dart';
import 'package:mobile_app_assignment/model/service.dart';
import '../services/service_service.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../model/global_user.dart';
import '../model/user.dart';
import '../services/user_service.dart';
import '../provider/navigation_provider.dart';
import '../view/service_details_view.dart';
import '../view/book_service_view.dart';
import '../widgets/service_item.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<StatefulWidget> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final ServiceService ss = ServiceService();
  final String userId = GlobalUser.user!.uid;
  String upcomingCount = "";
  String inProgressCount = "";
  String completedCount = "";

  List<Service> activeServices = [];
  List<Service> completedServices = [];
  List<Service> inProgressServices = [];

  void loadData() async {
    final active = await ss.getAllActiveServices(userId);
    final completed = await ss.getAllCompletedServices(userId);
    final inProgress = await ss.getInProgressServices(userId);

    setState(() {
      activeServices = active;
      completedServices = completed;
      inProgressServices = inProgress;

      upcomingCount = activeServices.length.toString();
      inProgressCount = inProgressServices.length.toString();
      completedCount = completedServices.length.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColor.softWhite,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            title: Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: Text(
                "Service Schedule",
                style: TextStyle(
                  color: AppColor.softWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            backgroundColor: AppColor.primaryGreen,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.softWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.darkCharcoal.withAlpha(63),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    width: 100,
                    height: 100,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Upcoming",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              upcomingCount,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.softWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.darkCharcoal.withAlpha(63),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    width: 100,
                    height: 100,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "In Progress",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              inProgressCount,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.softWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.darkCharcoal.withAlpha(63),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    width: 100,
                    height: 100,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              completedCount,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              inProgressServices.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: inProgressServices
                        .map((s) => ServiceItem(service: s, inProgress: true))
                        .toList(),
                  ),
                )
              : Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.softWhite,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.darkCharcoal.withAlpha(63),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                height: 40,
                width: 360,

                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColor.primaryGreen,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: AppColor.softWhite,
                  unselectedLabelColor: AppColor.darkCharcoal,
                  tabs: [
                    Tab(text: "Upcoming"),
                    Tab(text: "Completed"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    activeServices.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: activeServices
                                      .map(
                                        (s) => ServiceItem(
                                          service: s,
                                          inProgress: false,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        : Center(child: Text("No Upcoming Services")),
                    completedServices.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: completedServices
                                      .map(
                                        (s) => ServiceItem(
                                          service: s,
                                          inProgress: false,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        : Center(child: Text("No Completed Services")),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            backgroundColor: AppColor.primaryGreen,
            onPressed: () async {
              navigationProvider.showFullPageContent(
                BookServiceView(),
              );
            },
            child: const Icon(Icons.add, size: 32, color: AppColor.softWhite),
          ),
        ),
      ),
    );
  }
}
