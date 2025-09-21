import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_app_assignment/provider/navigation_provider.dart';
import 'package:mobile_app_assignment/services/reminder_service.dart';
import 'package:mobile_app_assignment/services/service_service.dart';
import 'package:mobile_app_assignment/services/vehicle_service.dart';
import 'package:mobile_app_assignment/view/book_service_view.dart';
import 'package:provider/provider.dart';

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
  final ServiceService ss = ServiceService();
  final ReminderService rs = ReminderService();
  final String userId = GlobalUser.user!.uid;
  List<Widget> reminderLayout = [];
  List<String> serviceCategory = [
    "Brake Service",
    "Engine Diagnostics",
    "Battery Replacement",
    "Air Conditioning Service",
    "Tire Replacement",
    "Suspension Inspection",
    "Transmission Service",
    "Radiator & Cooling System",
    "Power Steering Service",
    "Wiper Replacement",
    "Headlight/Taillight Replacement"
  ];
  void loadData() async {
    final vehicles = await vs.getAllVehicle(userId);

  }

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> loadReminders() async {
    final results = await Future.wait(serviceCategory.map(serviceReminder));
    print(results.length);
    setState(() {
      reminderLayout = results;
    });
  }

  double calculateDateProgress(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();

    if (now.isBefore(startDate)) return 0.0; // not started yet
    if (now.isAfter(endDate)) return 100.0;  // already finished

    final totalDuration = endDate.difference(startDate).inMilliseconds;
    final elapsed = now.difference(startDate).inMilliseconds;

    final percentage = (elapsed / totalDuration) * 100;
    return percentage;
  }

  Future<Widget> serviceReminder(String category) async {
    String lastServiceDisplay = "-";
    String dueAtDisplay = "-";
    double progressDisplay = 0;
    Color colorDisplay = AppColor.primaryGreen;
    final lastService = await ss.getSelectedCompletedServices(userId, category);
    if(lastService != null){
      lastServiceDisplay = DateFormat('dd MMM yyyy').format(lastService.appointmentDate!);
      final reminder = await rs.getReminder(userId, category);
      if(reminder != null && reminder.reminderDate != null){
        dueAtDisplay = DateFormat('dd MMM yyyy').format(reminder.reminderDate!);
        progressDisplay = calculateDateProgress(lastService.appointmentDate!, reminder.reminderDate!);
      }
    }
    if(progressDisplay >= 75){
      colorDisplay = AppColor.wineRed;
    }else if(progressDisplay >= 50){
      colorDisplay = Colors.deepOrangeAccent;
    }else if(progressDisplay > 0){
      colorDisplay = AppColor.primaryGreen;
    }

    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorDisplay),
            color: AppColor.softWhite,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorDisplay,
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
                            color: colorDisplay,
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
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: 130,
                            child: Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorDisplay.withAlpha(127),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: 75,
                      height: 25,
                      child: Center(
                        child: Text(
                          "Due Now",
                          style: TextStyle(
                              color: colorDisplay,
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
                              lastServiceDisplay,
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
                              dueAtDisplay,
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
                  value: progressDisplay,
                  backgroundColor: AppColor.darkCharcoal,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorDisplay,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 10,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      navigationProvider.showFullPageContent(
                        BookServiceView(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorDisplay,
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
    );
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
          children: reminderLayout, // map here
        ),
      ),
    );
  }
}
