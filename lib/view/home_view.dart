import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_app_assignment/services/vehicle_service.dart';

import '../core/theme/app_colors.dart';
import '../widgets/navbar_widget.dart';
import '../model/global_user.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final VehicleService vs = VehicleService();
  final String userId = GlobalUser.user?.uid ?? "7K3cULYkj8PPQCjDrxv6drIel3b2"; // delete default and !

  void loadData() async {
    final vehicles = await vs.getAllVehicle(userId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.softWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          toolbarHeight: 150,
          centerTitle: false,
          title: Padding(
            padding: EdgeInsets.only(left: 0, top: 0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome, ${GlobalUser.user?.email ?? 'Guest'}",
                    style: TextStyle(
                      color: AppColor.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
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
                      width: 380,
                      height: 70,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColor.softWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColor.wineRed,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.wineRed.withAlpha(63),
                                          blurRadius: 10,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.directions_car_filled_rounded,
                                      color: AppColor.wineRed,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Benz C63",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.darkCharcoal,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        width: 90,
                                        height: 25,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "BFP 1975",
                                          style: TextStyle(
                                            color: AppColor.softWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(35, 35),
                              ),
                              onPressed: () {},
                              child: Text(
                                "Switch",
                                style: TextStyle(color: AppColor.softWhite),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColor.primaryGreen,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.wineRed),
                    color: AppColor.softWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.wineRed,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  width: 380,
                  height: 230,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.wineRed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.settings_rounded,
                                    size: 36,
                                    color: AppColor.softWhite,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Brake Pads",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.wineRed.withAlpha(127),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: 75,
                              height: 25,
                              child: Center(
                                child: Text(
                                  "Due Now",
                                  style: TextStyle(
                                    color: AppColor.wineRed,
                                    fontWeight: FontWeight.bold
                                  ),

                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: 360,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      "Last Service",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      "20 Feb 2025",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      "Due At",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      "01 Aug 2025",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: LinearProgressIndicator(
                          value: 0.9,
                          backgroundColor: AppColor.darkCharcoal,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.wineRed,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 10,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.wineRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // fixedSize: const Size(160,40),
                              minimumSize: Size(170, 40),
                            ),
                            child: Text(
                              "Book Service",
                              style: TextStyle(
                                color: AppColor.softWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return Container(
                                    padding: EdgeInsets.all(20),
                                    height: 500,
                                    child: Center(child: Text("This is a bottom sheet overlay")),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.softWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: AppColor.darkCharcoal),
                              ),
                              minimumSize: Size(170, 40),
                            ),
                            child: Text(
                              "Set Reminder",
                              style: TextStyle(
                                color: AppColor.darkCharcoal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // return Center(
    //   child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           "Welcome, ${GlobalUser.user?.email ?? 'Guest'}",
    //           style: const TextStyle(
    //             fontSize: 20,
    //             fontWeight: FontWeight.bold,
    //             color: AppColor.darkCharcoal,
    //           ),
    //         ),
    //         const SizedBox(height: 16),
    //         Text(
    //           "UID: ${GlobalUser.user?.uid ?? 'N/A'}",
    //           style: const TextStyle(
    //             fontSize: 14,
    //             color: AppColor.slateGray,
    //           ),
    //         ),
    //       ],
    //     ),
    // );
  }
}
