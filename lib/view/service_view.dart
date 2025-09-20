import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../model/user.dart';
import '../services/user_service.dart';
import '../provider/navigation_provider.dart';
import '../view/service_details_view.dart';
import '../view/book_service_view.dart';
import '../widgets/base_page.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({super.key});

  Future<void> addCustomer() async {
    UserService users = UserService();
    // User user = User(id: "damnniu",email:"jasonnnnn@email.com", displayName: "WURR");
    // await users.addUser(user);
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
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
                              "2",
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
                              "1",
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
                              "9",
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
              // ----------------- IN PROGRESS PART ----------------- //
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
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
                  width: 360,
                  height: 160,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10, top: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColor.softWhite,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                width: 100,
                                child: Text(
                                  "Brake Oil Service",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10, right: 10),
                                child: Text(
                                  "IN INSPECTION",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5, right: 10),
                                child: Container(
                                  //color: AppColor.darkCharcoal,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.darkCharcoal,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Text(
                                    "BFP 1975",
                                    style: TextStyle(
                                      color: AppColor.softWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(
                        indent: 10, // adjust later
                        endIndent: 10,
                        color: AppColor.slateGray.withAlpha(63),
                        thickness: 1,
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "ETA : 3:00 PM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.softWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColor.darkCharcoal,
                                  width: 1,
                                ),
                              ),
                              minimumSize: const Size(340, 40),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ServiceDetailsView(),
                                ),
                              );
                            },
                            child: const Text(
                              "View Details",
                              style: TextStyle(color: AppColor.darkCharcoal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ----------------- IN PROGRESS END ----------------- //
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
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
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    Center(child: Text("Upcoming content goes here")),
                    Center(child: Text("Completed content goes here")),
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
            onPressed: () {
              navigationProvider.showFullPageContent(
                BasePage(child: BookServiceView()),
              );
            },
            child: const Icon(Icons.add, size: 32, color: AppColor.softWhite),
          ),
        ),
      ),
    );
  }
}
